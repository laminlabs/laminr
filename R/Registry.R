#' @title Registry
#'
#' @noRd
#'
#' @description
#' A registry in a module.
Registry <- R6::R6Class( # nolint object_name_linter
  "Registry",
  cloneable = FALSE,
  public = list(
    #' @param instance The instance the registry belongs to.
    #' @param module The module the registry belongs to.
    #' @param api The API for the instance.
    #' @param registry_name The name of the registry.
    #' @param registry_schema The schema for the registry.
    initialize = function(instance, module, api, registry_name, registry_schema) {
      private$.instance <- instance
      private$.module <- module
      private$.api <- api
      private$.registry_name <- registry_name
      private$.class_name <- registry_schema$class_name
      private$.is_link_table <- registry_schema$is_link_table
      private$.fields <- map(
        registry_schema$fields_metadata,
        function(field) {
          # note: the 'schema_name' and 'model_name' fields
          # are mapped to 'module_name' and 'registry_name' respectively
          Field$new(
            type = field$type,
            through = field$through,
            field_name = field$field_name,
            registry_name = field$model_name,
            column_name = field$column_name,
            module_name = field$schema_name,
            is_link_table = field$is_link_table,
            relation_type = field$relation_type,
            related_field_name = field$related_field_name,
            related_registry_name = field$related_model_name,
            related_module_name = field$related_schema_name
          )
        }
      ) |>
        set_names(names(registry_schema$fields_metadata))

      private$.record_class <- create_record_class(
        instance = instance,
        registry = self,
        api = api
      )
    },
    #' Get a record by ID or UID.
    get = function(id_or_uid, include_foreign_keys = TRUE, verbose = FALSE) {
      data <- private$.api$get_record(
        module_name = private$.module$name,
        registry_name = private$.registry_name,
        id_or_uid = id_or_uid,
        include_foreign_keys = include_foreign_keys,
        verbose = verbose
      )

      private$.record_class$new(data = data)
    },
    #' Get the fields in the registry.
    get_fields = function() {
      private$.fields
    },
    #' Get a field by name.
    get_field = function(field_name) {
      private$.fields[[field_name]]
    },
    #' Get the field names in the registry.
    get_field_names = function() {
      names(private$.fields)
    },
    #' Get the record class for the registry.
    get_record_class = function() {
      private$.record_class
    }
  ),
  private = list(
    .instance = NULL,
    .module = NULL,
    .api = NULL,
    .registry_name = NULL,
    .class_name = NULL,
    .is_link_table = NULL,
    .fields = NULL,
    .record_class = NULL
  ),
  active = list(
    #' @return The instance the registry belongs to.
    module = function() {
      private$.module
    },
    #' @return The API for the instance.
    name = function() {
      private$.registry_name
    },
    #' @return The class name for the registry.
    class_name = function() {
      private$.class_name
    },
    #' @return Whether the registry is a link table.
    is_link_table = function() {
      private$.is_link_table
    }
  )
)
