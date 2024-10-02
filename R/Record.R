create_record <- function(instance, model, api, data) {
  super <- NULL # satisfy linter

  # create active fields for the exposed instance
  active <- list()

  # add fields to active
  for (field_name in model$get_field_names()) {
    fun <- NULL
    fun_src <- paste0(
      "fun <- function() {",
      "  private$get_value('", field_name, "')",
      "}"
    )
    eval(parse(text = fun_src))

    active[[field_name]] <- fun
  }

  # determine the base class
  # (core.artifact gets additional methods)
  RecordClass <- # nolint object_name_linter
    if (model$module$name == "core" && model$name == "artifact") {
      Artifact
    } else {
      Record
    }

  # create the record class
  RichRecord <- R6::R6Class( # nolint object_name_linter
    "RichRecord",
    cloneable = FALSE,
    inherit = RecordClass,
    public = list(
      initialize = function(instance, model, api, data) {
        super$initialize(
          instance = instance,
          model = model,
          api = api,
          data = data
        )
      }
    ),
    active = active
  )

  # create the record
  RichRecord$new(instance, model, api, data)
}

Record <- R6::R6Class( # nolint object_name_linter
  "Record",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, model, api, data) {
      private$.instance <- instance
      private$.model <- model
      private$.api <- api
      private$.data <- data
    }
  ),
  private = list(
    .instance = NULL,
    .model = NULL,
    .api = NULL,
    .data = NULL,
    get_value = function(key) {
      if (key %in% names(private$.data)) {
        private$.data[[key]]
      } else if (key %in% private$.model$get_field_names()) {
        field <- private$.model$get_field(key)

        ## TODO: use related_model_class$get_records instead
        related_data <- private$.api$get_record(
          module_name = field$schema_name,
          model_name = field$model_name,
          id_or_uid = private$.data[["uid"]],
          select = key
        )[[key]]

        related_module_class <- private$.instance$get_module(field$related_schema_name)
        related_model_class <- related_module_class$get_model(field$related_model_name)

        if (field$relation_type %in% c("one-to-one", "many-to-one")) {
          related_model_class$cast_data_to_class(related_data)
        } else {
          map(related_data, related_model_class$cast_data_to_class)
        }
      } else {
        cli::cli_abort(
          paste0(
            "Field '", key, "' not found in model '",
            private$.model$name, "'"
          )
        )
      }
    }
  )
)
