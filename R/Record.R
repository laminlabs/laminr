create_record_class <- function(
    module_name,
    model_name,
    module,
    instance) {
  super <- NULL # satisfy R CMD check and lintr
  field_names <- map_chr(module$fields_metadata, "field_name")

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
    module$class_name,
    cloneable = FALSE,
    inherit = RecordClass,
    active = active,
    public = list(
      initialize = function(data) {
        super$initialize(
          data = data,
          instance = instance,
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
    initialize = function(data, instance, class_name, fields_metadata) {
      private$class_name <- class_name
      private$data <- data
      private$instance <- instance
      private$fields_metadata <- fields_metadata
    },
    print = function(...) {

      common_fields <- c("uid", "hash", "created_at", "updated_at")

      id_string <- ""
      if (!is.null(private$data$uid)) {
        id_string <- paste0(id_string, "UID:", private$data$uid)
      }
      if (!is.null(private$data$uid) && !is.null(private$data$hash)) {
        id_string <- paste0(id_string, " - ")
      }
      if (!is.null(private$data$hash)) {
        id_string <- paste0(id_string, "Hash:", private$data$hash)
      }

      cli::cat_rule(
        left = cli::style_inverse(private$class_name),
        right = id_string
      )
      # NOTE: could use private$fields instead of names(private$data)
      purrr::walk(names(private$data), function(.name) {
        if (.name %in% common_fields) {
          return()
        }

        value <- private$data[[.name]]
        if (is.character(value)) {
          value <- paste0("'", value, "'")
        }
        if (is.null(value)) {
          value <- "NULL"
        }
        cli::cat_line(cli::col_yellow(.name, ": "), cli::col_cyan(value))
      })

      date_string <- ""
      if (!is.null(private$data$created_at)) {
        id_string <- paste0(id_string, "Created:", private$data$created_at)
      }
      if (!is.null(private$data$created_at) &&
          !is.null(private$data$updated_at)) {
        id_string <- paste0(id_string, " - ")
      }
      if (!is.null(private$data$hash)) {
        id_string <- paste0(id_string, "Updated:", private$data$updated_at)
      }

      cli::cat_rule(
        right = paste0(
          "Created: ", private$data$created_at,
          " - ",
          "Updated: ", private$data$updated_at
        )
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
