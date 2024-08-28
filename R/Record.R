create_record_class <- function(
  module_name,
  model_name,
  module,
  get_record
) {
  field_names <- map_chr(module$fields_metadata, "field_name")

  record_class <- R6::R6Class(
    module$class_name,
    cloneable = FALSE,
    inherit = Record,
    active = map(
      field_names,
      function(field_name) {
        fun <- NULL
        fun_src <- paste0(
          "fun <- function(value) {\n",
          "  if (missing(value)) {\n",
          "    private$get_value('", field_name, "')\n",
          "  } else {\n",
          "    private$set_value('", field_name, "', value)\n",
          "  }\n",
          "}\n"
        )
        eval(parse(text = fun_src))
        fun
      }
    ) |>
      set_names(field_names),
    public = list(
      initialize = function(data) {
        super$initialize(
          data = data,
          get_record = get_record,
          class_name = module$class_name,
          fields_metadata = module$fields_metadata
        )
      },
      print = function(...) {
        super$print(...)
      }
    )
  )

  record_class$get <- function(id_or_uid) {
    get_record(
      module_name = module_name,
      model_name = model_name,
      id_or_uid = id_or_uid
    )
  }

  record_class
}

Record <- R6::R6Class( # nolint object_name_linter
  "Record",
  cloneable = FALSE,
  public = list(
    initialize = function(data, get_record, class_name, fields_metadata) {
      private$class_name <- class_name
      private$data <- data
      private$get_record <- get_record
      private$fields_metadata <- fields_metadata
    },
    print = function(...) {
      # NOTE: could use private$fields instead of names(private$data)
      data_names <- names(private$data)
      data_values <- sapply(
        unlist(private$data),
        function(x) {
          if (is.null(x)) {
            "NULL"
          } else if (is.character(x)) {
            paste0("'", x, "'")
          } else {
            x
          }
        }
      )
      data_str <- paste0(
        private$class_name, "(",
        paste(data_names, "=", data_values, collapse = ", "),
        ")"
      )
      cat(data_str, "\n", sep = "")
    }
  ),
  private = list(
    data = NULL,
    get_record = NULL,
    class_name = NULL,
    fields_metadata = NULL,
    get_value = function(field_name) {
      field_metadata <- private$fields_metadata[[field_name]]
      column_name <- field_metadata$column_name
      relation_type <- field_metadata$relation_type
      if (is.null(relation_type)) {
        private$data[[column_name]]
      } else {
        private$get_record(
          module_name = field_metadata$schema_name,
          model_name = field_metadata$model_name,
          id_or_uid = private$data$uid,
          field_name = field_name
        )
      }
    },
    set_value = function(field_name) {
      cli::cli_abort("Setting values is not supported yet")
    }
  )
)
