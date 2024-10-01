Record <- R6::R6Class( # nolint object_name_linter
  "Record",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, model, api, data) {
      private$.instance <- instance
      private$.model <- model
      private$.api <- api
      private$.data <- data
    },
    get = function(key) {
      if (key %in% names(private$.data)) {
        private$.data[[key]]
      } else if (key %in% names(private$.model$fields)) {
        field <- private$.model$fields[[key]]

        ## TODO: use related_model_class$get_records instead
        related_data <- private$.api$get_record(
          module_name = field$schema_name,
          model_name = field$model_name,
          id_or_uid = private$.data[["uid"]],
          select = key
        )[[key]]

        related_module_class <- instance$modules[[field$related_schema_name]]
        related_model_class <- related_module_class$models[[field$related_model_name]]

        if (field$relation_type %in% c("one-to-one", "many-to-one")) {
          related_model_class$cast_data_to_class(related_data)
        } else {
          map(related_data, related_model_class$cast_data_to_class)
        }

      } else {
        cli::cli_abort(
          "Field not found: ",
          key,
          " in model ",
          private$.model$name
        )
      }
    },
    keys = function() {
      names(private$.model$fields)
    }
  ),
  private = list(
    .instance = NULL,
    .model = NULL,
    .api = NULL,
    .data = NULL
  )
)
