create_instance <- function(instance_settings) {
  super <- NULL # satisfy linter

  api <- InstanceAPI$new(instance_settings = instance_settings)

  # fetch schema from the API
  schema <- api$get_schema()

  # create active fields for the exposed instance
  active <- list()

  # add core registries to active fields
  for (registry_name in names(schema$core)) {
    registry <- schema$core[[registry_name]]

    if (registry$is_link_table) {
      next
    }

    fun_src <- paste0(
      "function() {",
      "  private$.module_classes$core$get_registry('", registry_name, "')",
      "}"
    )

    active[[registry$class_name]] <- eval(parse(text = fun_src))
  }

  # add non-core modules to active fields
  for (module_name in names(schema)) {
    if (module_name == "core") {
      next
    }

    fun_src <- paste0(
      "function() {",
      "  private$.module_classes[['", module_name, "']]",
      "}"
    )
    active[[module_name]] <- eval(parse(text = fun_src))
  }

  # create the instance class
  RichInstance <- R6::R6Class( # nolint object_name_linter
    instance_settings$name,
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
  RichInstance$new(settings = instance_settings, api = api, schema = schema)
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
          create_module(
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
    },
    get_module = function(module_name) {
      # todo: assert module exists
      private$.module_classes[[module_name]]
    },
    get_module_names = function() {
      names(private$.module_classes)
    }
  ),
  private = list(
    .settings = NULL,
    .api = NULL,
    .module_classes = NULL
  )
)
