# todo: change arguments into 'module_class'
create_record_class <- function(
    module_name,
    model_name,
    model_schema,
    instance) {
  super <- NULL # satisfy R CMD check and lintr
  field_names <- map_chr(model_schema$fields_metadata, "field_name")

  # create fields for this class
  active <- map(
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
    set_names(field_names)
  
  active$is_link_table <- function() {
    private$is_link_table
  }

  # determine the base class
  # (core.artifact gets additional methods)
  RecordClass <- # nolint object_name_linter
    if (module_name == "core" && model_name == "artifact") {
      CoreArtifact
    } else {
      Record
    }

  # create the instanciated class
  record_class <- R6::R6Class(
    model_schema$class_name,
    cloneable = FALSE,
    inherit = RecordClass,
    active = active,
    public = list(
      initialize = function(data) {
        super$initialize(
          data = data,
          instance = instance,
          class_name = model_schema$class_name,
          fields_metadata = model_schema$fields_metadata,
          is_link_table = model_schema$is_link_table
        )
      },
      print = function(...) {
        super$print(...)
      },
      to_string = function(...) {
        super$to_string(...)
      }
    )
  )

  record_class$get <- function(id_or_uid) {
    instance$`.__enclos_env__`$private$get_record(
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
    initialize = function(data, instance, class_name, fields_metadata, is_link_table) {
      private$data <- data
      private$instance <- instance
      private$class_name <- class_name
      private$fields_metadata <- fields_metadata
      private$is_link_table <- is_link_table
    },
    print = function(...) {
      cat(paste(self$to_string(...), "\n", sep = "", collapse = "\n"))
    },
    to_string = function(...) {
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
      paste0(
        private$class_name, "(",
        paste(data_names, "=", data_values, collapse = ", "),
        ")"
      )
    }
  ),
  private = list(
    data = NULL,
    instance = NULL,
    class_name = NULL,
    fields_metadata = NULL,
    get_value = function(field_name) {
      field_metadata <- private$fields_metadata[[field_name]]
      column_name <- field_metadata$column_name
      relation_type <- field_metadata$relation_type
      if (is.null(relation_type)) {
        private$data[[column_name]]
      } else {
        private$instance$`.__enclos_env__`$private$get_record(
          module_name = field_metadata$schema_name,
          model_name = field_metadata$model_name,
          id_or_uid = private$data$uid,
          select = field_name
        )
      }
    },
    set_value = function(field_name) {
      cli::cli_abort("Setting values is not supported yet")
    }
  )
)
