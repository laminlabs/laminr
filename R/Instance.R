
Instance <- R6::R6Class(
  "Instance",
  cloneable = FALSE,
  public = list(
    #' Initialize the Instance class
    #'
    #' @param instance_settings The settings of the LaminDB instance.
    #'
    #' @noRd
    #'
    #' @importFrom R6 R6Class
    #' @importFrom httr GET POST content add_headers
    #' @importFrom purrr map map_chr map2 set_names
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

    ## API FUNCTIONS
    api_get_schema = function() {
      instance_settings <- private$instance_settings
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
      # NOTE: allow turning off logging
      field_name_str <-
        if (!is.null(field_name)) {
          paste0(", field_name '", field_name, "'")
        } else {
          ""
        }
      cli::cli_inform(paste0(
        "Getting record from module '", module_name, "',",
        "model '", model_name, "',",
        "id_or_uid '", id_or_uid, "',",
        field_name_str, "\n"
      ))
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
      # NOTE: allow printing the data if logging is enabled
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

    ## HELPER FUNCTIONS
    create_classes = function() {
      # use lapply instead of map to retain names
      module_names <- names(private$schema)
      private$classes <- map(
        module_names,
        function(module_name) {
          model_names <- names(private$schema[[module_name]])
          map(
            model_names,
            function(model_name) {
              private$generate_class(
                module_name = module_name,
                model_name = model_name
              )
            }
          ) |>
            set_names(model_names)
        }
      ) |>
        set_names(module_names)
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
      
      class <- private$classes[[module_name]][[model_name]]
      class$new(data)
    },
    
    generate_class = function(
      module_name,
      model_name
    ) {
      module <- private$schema[[module_name]][[model_name]]
      field_names <- map_chr(module$fields_metadata, "field_name")
      instance <- self
      class_name <- module$class_name

      class <- R6::R6Class(
        class_name,
        cloneable = FALSE,
        active = map(
          field_names,
          function(field_name) {
            fun <- NULL
            fun_src <- paste0(
              "fun <- function(value) {",
              "  if (missing(value)) {",
              "    private$get_value('", field_name, "')",
              "  } else {",
              "    private$set_value('", field_name, "', value)",
              "  }",
              "}"
            )
            eval(parse(text = fun_src))
            fun
          }
        ) |>
          set_names(field_names),
        public = list(
          initialize = function(data) {
            private$data <- data
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
          instance = instance,
          fields_metadata = module$fields_metadata,
          get_value = function(field_name) {
            field_metadata <- private$fields_metadata[[field_name]]
            column_name <- field_metadata$column_name
            relation_type <- field_metadata$relation_type
            if (is.null(relation_type)) {
              private$data[[column_name]]
            } else {
              # TODO: expose `api_get_record` in a logical manner
              instance$.__enclos_env__$private$api_get_record(
                module_name = module_name,
                model_name = model_name,
                id_or_uid = private$data$uid,
                field_name = field_name
              )
            }
          },
          set_value = function(field_name) {
            cli::cli_abort("Setting values is not supported yet")
          }
        )
      )

      class$get <- function(id_or_uid) {
        private$api_get_record(
          module_name = module_name,
          model_name = model_name,
          id_or_uid = id_or_uid
        )
      }

      class
    }
  )
)



