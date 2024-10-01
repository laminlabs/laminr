create_instance <- function(settings) {
  private <- super <- NULL # satisfy linter

  api <- API$new(
    api_url = settings$api_url,
    instance_id = settings$id,
    schema_id = settings$schema_id
  )

  # fetch schema from the API
  schema <- api$get_schema()

  # create active fields for the exposed instance
  active <- list()

  # add core models to active fields
  for (model_name in names(schema$core)) {
    model <- schema$core[[model_name]]
    if (model$is_link_table) {
      next
    }
    active[[model_name]] <- function() {
      private$.module_classes$core$models[[model_name]]
    }
  }

  # add non-core modules to active fields
  for (module_name in names(schema)) {
    if (module_name == "core") {
      next
    }

    active[[module_name]] <- function() {
      private$.module_classes[[module_name]]
    }
  }

  # create the instance class
  CurrentInstance <- R6::R6Class( # nolint object_name_linter
    settings$name,
    cloneable = FALSE,
    inherit = Instance,
    public = list(
      initialize = function(settings, api, schema) {
        super$initialize(
          settings = settings,
          api = api,
          schema = schema
        )
      }
    ),
    active = active
  )

  # create the instance
  CurrentInstance$new(settings = settings, api = api, schema = schema)
}

Instance <- R6::R6Class( # nolint object_name_linter
  "Instance",
  cloneable = FALSE,
  public = list(
    initialize = function(settings, api, schema) {
      private$.settings <- settings
      private$.api <- api

      # create module classes from the schema
      private$.module_classes <- map(
        names(schema),
        function(module_name) {
          Module$new(
            instance = self,
            api = private$.api,
            module_name = module_name,
            module_schema = schema[[module_name]]
          )
        }
      ) |>
        set_names(names(schema))
    },
    get_modules = function() {
      private$.module_classes
    }
  ),
  private = list(
    .settings = NULL,
    .api = NULL,
    .module_classes = NULL
  )
)
