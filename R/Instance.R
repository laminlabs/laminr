create_instance_class <- function(instance_settings) {
  name <- paste0(instance_settings$owner, "/", instance_settings$name)
  schema <- api_get_schema(instance_settings)

  # use lapply instead of map to retain names
  classes <- map(
    names(schema),
    function(module_name) {
      model_names <- names(schema[[module_name]])
      map(
        model_names,
        function(model_name) {
          list(
            module_name = module_name,
            model_name = model_name,
            class_name = schema[[module_name]][[model_name]]$class_name
          )
        }
      )
    }
  ) |>
    list_flatten() |>
    transpose()

  active <- pmap(
    classes,
    function(module_name, model_name, class_name) {
      fun <- NULL
      fun_src <- paste0(
        "fun <- function() {\n",
        "  private$classes[['", module_name, "']][['", model_name, "']]\n",
        "}\n"
      )
      eval(parse(text = fun_src))
      fun
    }
  ) |>
    set_names(classes$class_name)

  instance_class <- R6::R6Class(
    name,
    cloneable = FALSE,
    inherit = Instance,
    active = active,
    public = list(
      initialize = function(instance_settings, schema) {
        super$initialize(instance_settings, schema)
      }
    )
  )

  instance_class$new(instance_settings, schema)
}

Instance <- R6::R6Class(
  "Instance",
  cloneable = FALSE,
  public = list(
    #' Initialize the Instance class
    #'
    #' @param instance_settings The settings of the LaminDB instance.
    #'
    #' @noRd
    initialize = function(instance_settings, schema) {
      private$instance_settings <- instance_settings
      private$schema <- schema

      module_names <- names(schema)
      private$classes <- map(
        module_names,
        function(module_name) {
          model_names <- names(schema[[module_name]])
          map(
            model_names,
            function(model_name) {
              create_record_class(
                module_name = module_name,
                model_name = model_name,
                module = private$schema[[module_name]][[model_name]],
                get_record = private$get_record
              )
            }
          ) |>
            set_names(model_names)
        }
      ) |>
        set_names(module_names)
    }
  ),
  private = list(
    instance_settings = NULL,
    schema = NULL,
    classes = NULL,

    ## HELPER FUNCTIONS
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
