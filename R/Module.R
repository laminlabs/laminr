create_module <- function(instance, api, module_name, module_schema) {
  super <- NULL # satisfy linter

  # create active fields for the exposed instance
  active <- list()

  # add registries to active fields
  for (registry_name in names(module_schema)) {
    registry <- module_schema[[registry_name]]

    if (registry$is_link_table) {
      next
    }

    fun_src <- paste0(
      "function() {",
      "  private$.registry_classes[['", registry_name, "']]",
      "}"
    )
    active[[registry$class_name]] <- eval(parse(text = fun_src))
  }

  # create the module class
  RichModule <- R6::R6Class( # nolint object_name_linter
    module_name,
    cloneable = FALSE,
    inherit = Module,
    public = list(
      initialize = function(instance, api, module_name, module_schema) {
        super$initialize(
          instance = instance,
          api = api,
          module_name = module_name,
          module_schema = module_schema
        )
      }
    ),
    active = active
  )

  # create the module
  RichModule$new(instance, api, module_name, module_schema)
}

#' @title Module
#'
#' @noRd
#'
#' @description
#' A LaminDB module containing one or more registries.
Module <- R6::R6Class( # nolint object_name_linter
  "Module",
  cloneable = FALSE,
  public = list(
    #' @param instance The instance the module belongs to.
    #' @param api The API for the instance.
    #' @param module_name The name of the module.
    initialize = function(instance, api, module_name, module_schema) {
      private$.instance <- instance
      private$.api <- api
      private$.module_name <- module_name

      private$.registry_classes <- map(
        names(module_schema),
        function(registry_name) {
          Registry$new(
            instance = instance,
            module = self,
            api = api,
            registry_name = registry_name,
            registry_schema = module_schema[[registry_name]]
          )
        }
      ) |>
        set_names(names(module_schema))
    },
    #' Get the registries in the module.
    get_registries = function() {
      private$.registry_classes
    },
    #' Get a registry by name.
    get_registry = function(registry_name) {
      private$.registry_classes[[registry_name]]
    },
    #' Get the names of the registries in the module. E.g. `c("User", "Artifact")`.
    get_registry_names = function() {
      names(private$.registry_classes)
    }
  ),
  private = list(
    .instance = NULL,
    .api = NULL,
    .module_name = NULL,
    .registry_classes = NULL
  ),
  active = list(
    #' Get the name of the module.
    name = function() {
      private$.module_name
    }
  )
)
