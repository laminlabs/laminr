Model <- R6::R6Class( # nolint object_name_linter
  "Model",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, module, api, model_name, model_schema) {
      private$.instance <- instance
      private$.module <- module
      private$.api <- api
      private$.model_name <- model_name
      private$.class_name <- model_schema$class_name
      private$.is_link_table <- model_schema$is_link_table
      private$.fields <- map(
        model_schema$fields_metadata,
        function(field) {
          Field$new(
            type = field$type,
            through = field$through,
            field_name = field$field_name,
            model_name = field$model_name,
            column_name = field$column_name,
            schema_name = field$schema_name,
            is_link_table = field$is_link_table,
            relation_type = field$relation_type,
            related_field_name = field$related_field_name,
            related_model_name = field$related_model_name,
            related_schema_name = field$related_schema_name
          )
        }
      ) |>
        set_names(names(model_schema$fields_metadata))
    },
    get_fields = function() {
      private$.fields
    },
    get_record = function(id_or_uid, include_foreign_keys = TRUE, verbose = FALSE) {
      data <- private$.api$get_record(
        module_name = private$.module$name,
        model_name = private$.model_name,
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

      create_record(
        instance = private$.instance,
        model = self,
        api = private$.api,
        data = data
      )
    }
  ),
  private = list(
    .instance = NULL,
    .module = NULL,
    .api = NULL,
    .model_name = NULL,
    .class_name = NULL,
    .is_link_table = NULL,
    .fields = NULL
  ),
  active = list(
    module = function() {
      private$.module
    },
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
