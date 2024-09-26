create_model_class <- function(instance, model_name, model_schema) {
  private <- super <- NULL # satisfy R CMD check and lintr

  # create helper functions for each record in the schema
  active <- list()

  for (model_name in names(model_schema)) {
    class_name <- model_schema[[model_name]]$class_name

    active[[class_name]] <- function() {
      private$record_classes[[model_name]]
    }
  }

  # create the instance class
  instance_class <- R6::R6Class(
    model_name,
    cloneable = FALSE,
    inherit = Model,
    active = active,
    public = list(
      initialize = function(instance, model_name, model_schema) {
        super$initialize(instance, model_name, model_schema)
      },
      print = function(...) {
        super$print(...)
      },
      to_string = function(...) {
        super$to_string(...)
      }
    )
  )

  active$records <- function() {
    private$record_classes
  }

  instance_class$new(instance, model_name, model_schema)
}

Model <- R6::R6Class( # nolint object_name_linter
  "Model",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, model_name, model_schema) {
      private$instance <- instance
      private$model_name <- model_name
      private$model_schema <- model_schema

      model_names <- names(model_schema)

      private$record_classes <- map(
        model_names,
        function(model_name) {
          create_record_class(
            model_name = model_name,
            model_name = model_name,
            model_schema = model_schema[[model_name]],
            instance = instance
          )
        }
      ) |>
        set_names(model_names)
    },
    print = function(...) {
      cat(paste(self$to_string(...), "\n", sep = "", collapse = "\n"))
    },
    to_string = function(show_link_tables = FALSE) {
      out <- c(
        paste0("Model ", private$model_name, " classes:")
      )
      for (record_class in private$record_classes) {
        if (show_link_tables || !record_class$is_link_table) {
          out <- c(
            out,
            paste0("  ", record_class$name)
          )
        }
      }
      out
    }
  ),
  private = list(
    instance = NULL,
    model_name = NULL,
    model_schema = NULL,
    record_classes = NULL,

    ## HELPER FUNCTIONS
    # get_record fetches a record from the lamindb API
    # and casts the data to the appropriate class
    get_record = function(model_name, model_name, id_or_uid, select = NULL) {
      data <- api_get_record(
        instance_settings = private$instance_settings,
        model_name = model_name,
        model_name = model_name,
        id_or_uid = id_or_uid,
        select = select,
        include_foreign_keys = TRUE
      )
      # use 'select' to select a related field instead of the main data itself
      if (!is.null(select)) {
        related_data <- data[[select]]
        schema_info <- private$schema[[model_name]][[model_name]]$fields_metadata[[select]]
        related_model_name <- schema_info$related_schema_name
        related_model_name <- schema_info$related_model_name
        relation_type <- schema_info$relation_type
        if (relation_type == "one-to-one" || relation_type == "many-to-one") {
          private$cast_data_to_class(related_model_name, related_model_name, related_data)
        } else {
          map(related_data, function(item) {
            private$cast_data_to_class(related_model_name, related_model_name, item)
          })
        }
      } else {
        private$cast_data_to_class(model_name, model_name, data)
      }
    },
    cast_data_to_class = function(model_name, model_name, data) {
      if (is.null(private$schema[[model_name]])) {
        cli::cli_abort(paste0("Model '", model_name, "' not found"))
      }
      model <- private$schema[[model_name]][[model_name]]
      if (is.null(model)) {
        cli::cli_abort(paste0("Model '", model_name, ".", model_name, "' not found"))
      }
      fields_metadata <- model$fields_metadata
      column_names <- map(fields_metadata, "column_name") |>
        unlist() |>
        unname()
      if (!all(names(data) %in% column_names)) {
        cli::cli_warn(paste0(
          "Data contains unexpected fields: ",
          paste(setdiff(names(data), column_names), collapse = ", ")
        ))
      }
      if (!all(column_names %in% names(data))) {
        cli::cli_warn(paste0(
          "Data is missing expected fields: ",
          paste(setdiff(column_names, names(data)), collapse = ", ")
        ))
      }

      private$classes[[model_name]][[model_name]]$new(data)
    }
  )
)
