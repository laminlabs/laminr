Instance <- R6::R6Class( # nolint object_name_linter
  "Instance",
  cloneable = FALSE,
  public = list(
    initialize = function(api_url, instance_id, schema_id) {
      private$.api <- API$new(
        api_url = api_url,
        instance_id = instance_id,
        schema_id = schema_id
      )

      # fetch schema from the API
      schema <- private$.api$get_schema()

      # create module classes from the schema
      private$.module_classes <- map(
        names(schema),
        function(module_name) {
          Module$new(
            instance = self,
            module_name = module_name,
            module_schema = schema[[module_name]]
          )
        }
      ) |>
        set_names(names(schema))
    }
  ),
  private = list(
    .api = NULL,
    .module_classes = NULL
  ),
  active = list(
    modules = function() {
      private$.module_classes
    }
  )
)
