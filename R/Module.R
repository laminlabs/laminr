create_module_class <- function(instance, module_name, module_schema) {
  private <- super <- NULL # satisfy R CMD check and lintr

  # create helper functions for each record in the schema
  active <- list()

  for (model_name in names(module_schema)) {
    class_name <- module_schema[[model_name]]$class_name

    active[[class_name]] <- function() {
      private$record_classes[[model_name]]
    }
  }

  # create the instance class
  instance_class <- R6::R6Class(
    module_name,
    cloneable = FALSE,
    inherit = Module,
    active = active,
    public = list(
      initialize = function(instance, module_name, module_schema) {
        super$initialize(instance, module_name, module_schema)
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

  instance_class$new(instance, module_name, module_schema)
}

Module <- R6::R6Class( # nolint object_name_linter
  "Module",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, module_name, module_schema) {
      private$instance <- instance
      private$module_name <- module_name
      private$module_schema <- module_schema

      model_names <- names(module_schema)

      private$record_classes <- map(
        model_names,
        function(model_name) {
          create_record_class(
            module_name = module_name,
            model_name = model_name,
            model_schema = module_schema[[model_name]],
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
        paste0("Module ", private$module_name, " classes:")
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
    module_name = NULL,
    module_schema = NULL,
    record_classes = NULL,

    ## HELPER FUNCTIONS
    # get_record fetches a record from the lamindb API
    # and casts the data to the appropriate class
    get_record = function(module_name, model_name, id_or_uid, select = NULL) {
      data <- api_get_record(
        instance_settings = private$instance_settings,
        module_name = module_name,
        model_name = model_name,
        id_or_uid = id_or_uid,
        select = select,
        include_foreign_keys = TRUE
      )
      # use 'select' to select a related field instead of the main data itself
      if (!is.null(select)) {
        related_data <- data[[select]]
        schema_info <- private$schema[[module_name]][[model_name]]$fields_metadata[[select]]
        related_module_name <- schema_info$related_schema_name
        related_model_name <- schema_info$related_model_name
        relation_type <- schema_info$relation_type
        if (relation_type == "one-to-one" || relation_type == "many-to-one") {
          private$cast_data_to_class(related_module_name, related_model_name, related_data)
        } else {
          map(related_data, function(item) {
            private$cast_data_to_class(related_module_name, related_model_name, item)
          })
        }
      } else {
        private$cast_data_to_class(module_name, model_name, data)
      }
    },
    cast_data_to_class = function(module_name, model_name, data) {
      if (is.null(private$schema[[module_name]])) {
        cli::cli_abort(paste0("Module '", module_name, "' not found"))
      }
      module <- private$schema[[module_name]][[model_name]]
      if (is.null(module)) {
        cli::cli_abort(paste0("Model '", module_name, ".", model_name, "' not found"))
      }
      fields_metadata <- module$fields_metadata
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

      private$classes[[module_name]][[model_name]]$new(data)
    }
  )
)
