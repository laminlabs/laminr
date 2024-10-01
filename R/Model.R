Model <- R6::R6Class( # nolint object_name_linter
  "Model",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, module_name, model_name, model_schema) {
      private$.instance <- instance
      private$.module_name <- module_name
      private$.model_name <- model_name
      private$.class_name <- model_schema$class_name
      private$.is_link_table <- model_schema$is_link_table
      private$.fields_metadata <- model_schema$fields_metadata
    }
  ),
  private = list(
    .instance = NULL,
    .module_name = NULL,
    .model_name = NULL,
    .class_name = NULL,
    .is_link_table = NULL,
    .fields_metadata = NULL
  ),
  active = list(
    name = function() {
      private$.model_name
    },
    class_name = function() {
      private$.class_name
    },
    is_link_table = function() {
      private$.is_link_table
    }
  )
)
