


Instance <- R6::R6Class(
  "Instance",
  cloneable = FALSE,
  public = list(
    #' Initialize the Instance class
    #'
    #' @param instance_settings The settings of the LaminDB instance.
    #'
    #' @noRd
    initialize = function(instance_settings) {
      private$instance_settings <- instance_settings

      private$schema <- private$api_get_schema()

      private$classes <- private$create_classes()
    }
  ),
  private = list(
    instance_settings = NULL,
    schema = NULL,
    classes = NULL,
    api_get_schema = function() {
      httr::GET(
        paste0(
          instance_settings$url,
          "/instances/",
          instance_settings$instance_id,
          "/schema"
        )
      ) |>
        httr::content()
    },
    api_get_record = function(module_name, model_name, id_or_uid, field_name = NULL) {
      instance_settings <- private$instance_settings
      body <-
        if (is.null(field_name)) {
          "{}"
        } else {
          paste0("{\"select\": [\"", field_name, "\"]}")
        }
      data <-
        httr::POST(
          paste0(
            instance_settings$url,
            "/instances/",
            instance_settings$instance_id,
            "/modules/",
            module_name,
            "/",
            model_name,
            "/",
            id_or_uid,
            "?schema_id=",
            instance_settings$schema_id
          ),
          httr::add_headers(
            accept = "application/json",
            `Content-Type` = "application/json"
          ),
          body = body
        ) |>
        httr::content()
      if (!is.null(field_name)) {
        related_data <- data[[field_name]]
        schema_info <- private$schema[[module_name]][[model_name]]$fields_metadata[[field_name]]
        related_module_name <- schema_info$related_schema_name
        related_model_name <- schema_info$related_model_name
        relation_type <- schema_info$relation_type
        if (relation_type == "one-to-one" || relation_type == "many-to-one") {
          private$cast_data_to_class(related_module_name, related_model_name, related_data)
        } else {
          lapply(related_data, function(item) {
            private$cast_data_to_class(related_module_name, related_model_name, item)
          })
        }
      } else {
        private$cast_data_to_class(module_name, model_name, data)
      }
    },
    create_classes = function() {
      private$classes <- lapply(
        private$schema,
        function(module) {
          lapply(
            module,
            function(model) {
              # private$generate_class(
              #   class_name = model$class_name,
              #   fields_metadata = model$fields_metadata
              # )
              generate_class(
                class_name = model$class_name,
                fields_metadata = model$fields_metadata,
                instance = self
              )
            }
          )
        }
      )
    },
    cast_data_to_class = function(module_name, model_name, data) {
      fields_metadata <- private$schema[[module_name]][[model_name]]$fields_metadata
      column_names <- map(fields_metadata, "column_name") |>
        unlist() |>
        unname()
      if (!all(names(data) %in% column_names)) {
        warning(paste0(
          "Data contains unexpected fields: ",
          paste(setdiff(names(data), column_names), collapse = ", ")
        ))
      }
      if (!all(column_names %in% names(data))) {
        warning(paste0(
          "Data is missing expected fields: ",
          paste(setdiff(column_names, names(data)), collapse = ", ")
        ))
      }
      
      class <- private$classes[[module_name]][[model_name]]
      class$new(data, self)
    }
  )
)



generate_class <- function(
  class_name,
  fields_metadata,
  instance
) {
  # fields_df <- dynutils::list_as_tibble(fields_metadata)

  class_generator <- R6::R6Class(
    class_name,
    cloneable = FALSE,
    active = setNames(
      map(
        fields_metadata,
        function(field_metadata) {
          column_name <- field_metadata$column_name
          relation_type <- field_metadata$relation_type

          if (is.null(relation_type)) {
            function(value) {
              if (missing(value)) {
                private$data[[column_name]]
              } else {
                stop("Setting values is not supported yet")
              }
            }
          } else {
            module_name <- field_metadata$schema_name
            model_name <- field_metadata$model_name
            field_name <- field_metadata$field_name

            function(value) {
              if (missing(value)) {
                private$instance$api_get_record(
                  module_name = module_name,
                  model_name = model_name,
                  uid = private$data[[column_name]]$uid,
                  field_name = field_name
                )
              } else {
                stop("Setting values is not supported yet")
              }
            }
          }
        }
      ),
      map_chr(fields_metadata, "field_name")
    ),
    public = list(
      initialize = function(data, instance) {
        private$data <- data
        private$instance <- instance
      },
      print = function(...) {
        # NOTE: could use private$fields instead of names(private$data)
        data_names <- names(private$data)
        data_values <- sapply(
          unlist(private$data),
          function(x) {
            if (is.null(x)) {
              "NULL"
            } else if (is.character(x)) {
              paste0("'", x, "'")
            } else {
              x
            }
          }
        )
        data_str <- paste0(
          class_name, "(",
          paste(data_names, "=", data_values, collapse = ", "),
          ")"
        )
        cat(data_str, "\n", sep = "")
      }
    ),
    private = list(
      data = NULL,
      instance = NULL
    )
  )
}
