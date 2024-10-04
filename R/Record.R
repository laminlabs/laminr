create_record_class <- function(instance, registry, api) {
  super <- NULL # satisfy linter

  # create active fields for the exposed instance
  active <- list()

  # add fields to active
  for (field_name in registry$get_field_names()) {
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
    if (registry$module$name == "core" && registry$name == "artifact") {
      Artifact
    } else {
      Record
    }

  # create the record class
  RichRecordClass <- R6::R6Class( # nolint object_name_linter
    "RichRecord",
    cloneable = FALSE,
    inherit = RecordClass,
    public = list(
      initialize = function(data) {
        super$initialize(
          instance = instance,
          registry = registry,
          api = api,
          data = data
        )
      }
    ),
    active = active
  )

  # create the record
  RichRecordClass
}

Record <- R6::R6Class( # nolint object_name_linter
  "Record",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, registry, api, data) {
      private$.instance <- instance
      private$.registry <- registry
      private$.api <- api
      private$.data <- data

      column_names <- map(registry$get_fields(), "column_name") |>
        unlist() |>
        unname()

      unexpected_fields <- setdiff(names(data), column_names)
      if (length(unexpected_fields) > 0) {
        cli_warn(
          paste0(
            "Data contains unexpected fields: ",
            paste(unexpected_fields, collapse = ", ")
          )
        )
      }

      missing_fields <- setdiff(column_names, names(data))
      if (length(missing_fields) > 0) {
        cli_warn(
          paste0(
            "Data is missing expected fields: ",
            paste(missing_fields, collapse = ", ")
          )
        )
      }
    }
  ),
  private = list(
    .instance = NULL,
    .registry = NULL,
    .api = NULL,
    .data = NULL,
    get_value = function(key) {
      if (key %in% names(private$.data)) {
        private$.data[[key]]
      } else if (key %in% private$.registry$get_field_names()) {
        field <- private$.registry$get_field(key)

        ## TODO: use related_registry_class$get_records instead
        related_data <- private$.api$get_record(
          module_name = field$module_name,
          registry_name = field$registry_name,
          id_or_uid = private$.data[["uid"]],
          select = key
        )[[key]]

        related_module <- private$.instance$get_module(field$related_module_name)
        related_registry <- related_module$get_registry(field$related_registry_name)
        related_registry_class <- related_registry$get_record_class()

        if (field$relation_type %in% c("one-to-one", "many-to-one")) {
          related_registry_class$new(related_data)
        } else {
          map(related_data, ~ related_registry_class$new(.x))
        }
      } else {
        cli_abort(
          paste0(
            "Field '", key, "' not found in registry '",
            private$.registry$name, "'"
          )
        )
      }
    }
  )
)
