
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

      private$schema <- api_get_schema(private$instance_settings)

      private$classes <- private$create_classes()
    }
  ),
  private = list(
    instance_settings = NULL,
    schema = NULL,
    classes = NULL,

    ## API FUNCTIONS
    get_record = function(module_name, model_name, id_or_uid, field_name = NULL) {
      data <- api_get_record(
        instance_settings = private$instance_settings,
        module_name = module_name,
        model_name = model_name,
        id_or_uid = id_or_uid,
        select = field_name
      )
      if (!is.null(field_name)) {
        related_data <- data[[field_name]]
        schema_info <- private$schema[[module_name]][[model_name]]$fields_metadata[[field_name]]
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
      
      private$classes[[module_name]][[model_name]]$new(data)
    },
    
    generate_class = function(
      module_name,
      model_name
    ) {
      module <- private$schema[[module_name]][[model_name]]
      field_names <- map_chr(module$fields_metadata, "field_name")
      get_record <- private$get_record

      record_class <- R6::R6Class(
        module$class_name,
        cloneable = FALSE,
        inherit = Record,
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
            super$initialize(
              data = data,
              get_record = get_record,
              class_name = module$class_name,
              fields_metadata = module$fields_metadata
            )
          }
        )
      )

      record_class$get <- function(id_or_uid) {
        private$get_record(
          module_name = module_name,
          model_name = model_name,
          id_or_uid = id_or_uid
        )
      }

      record_class
    }
  )
)



