Module <- R6::R6Class( # nolint object_name_linter
  "Module",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, api, module_name, module_schema) {
      private$.instance <- instance
      private$.api <- api
      private$.module_name <- module_name

      private$.model_classes <- map(
        names(module_schema),
        function(model_name) {
          Model$new(
            instance = instance,
            module = self,
            api = api,
            module_name = module_name,
            model_name = model_name,
            model_schema = module_schema[[model_name]]
          )
        }
      ) |>
        set_names(names(module_schema))
    }
  ),
  private = list(
    .instance = NULL,
    .api = NULL,
    .module_name = NULL,
    .model_classes = NULL
  ),
  active = list(
    name = function() {
      private$.module_name
    },
    models = function() {
      private$.model_classes
    }
  )
)
