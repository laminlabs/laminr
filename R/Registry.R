Registry <- R6::R6Class( # nolint object_name_linter
  "Registry",
  cloneable = FALSE,
  public = list(
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
    get_fields = function() {
      private$.fields
    },
    get_field = function(field_name) {
      private$.fields[[field_name]]
    },
    get_field_names = function() {
      names(private$.fields)
    },
    get = function(id_or_uid, include_foreign_keys = TRUE, verbose = FALSE) {
      data <- private$.api$get_record(
        module_name = private$.module$name,
        registry_name = private$.registry_name,
        id_or_uid = id_or_uid,
        include_foreign_keys = include_foreign_keys,
        verbose = verbose
      )

      self$cast_data_to_class(data)
    },
    cast_data_to_class = function(data) {
      column_names <- map(private$.fields, "column_name") |>
        unlist() |>
        unname()

      if (!all(names(data) %in% column_names)) {
        cli_warn(paste0(
          "Data contains unexpected fields: ",
          paste(setdiff(names(data), column_names), collapse = ", ")
        ))
      }

      if (!all(column_names %in% names(data))) {
        cli_warn(paste0(
          "Data is missing expected fields: ",
          paste(setdiff(column_names, names(data)), collapse = ", ")
        ))
      }

      private$.record_class$new(
        data = data
      )
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
    module = function() {
      private$.module
    },
    name = function() {
      private$.registry_name
    },
    class_name = function() {
      private$.class_name
    },
    is_link_table = function() {
      private$.is_link_table
    }
  )
)
