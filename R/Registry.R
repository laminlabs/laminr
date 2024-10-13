#' @title Registry
#'
#' @description
#' A registry in a module.
Registry <- R6::R6Class( # nolint object_name_linter
  "Registry",
  cloneable = FALSE,
  public = list(
    #' @description
    #' Creates an instance of this R6 class. This class should not be instantiated directly,
    #' but rather by connecting to a LaminDB instance using the [connect()] function.
    #'
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
    #' @description
    #' Get a record by ID or UID.
    #'
    #' @param id_or_uid The ID or UID of the record.
    #' @param include_foreign_keys Logical, whether to include foreign keys in the record.
    #' @param verbose Logical, whether to print verbose output.
    #'
    #' @return A [Record] object.
    get = function(id_or_uid, include_foreign_keys = FALSE, verbose = FALSE) {
      data <- private$.api$get_record(
        module_name = private$.module$name,
        registry_name = private$.registry_name,
        id_or_uid = id_or_uid,
        include_foreign_keys = include_foreign_keys,
        verbose = verbose
      )

      private$.record_class$new(data = data)
    },
    #' @description
    #' Get the fields in the registry.
    #'
    #' @return A list of [Field] objects.
    get_fields = function() {
      private$.fields
    },
    #' @description
    #' Get a field by name.
    #'
    #' @param field_name The name of the field.
    #'
    #' @return A [Field] object.
    get_field = function(field_name) {
      private$.fields[[field_name]]
    },
    #' @description
    #' Get the field names in the registry.
    #'
    #' @return A character vector of field names.
    get_field_names = function() {
      names(private$.fields)
    },
    #' @description
    #' Get the record class for the registry.
    #'
    #' Note: This method is intended for internal use only and may be removed in the future.
    #'
    #' @return A [Record] class.
    get_record_class = function() {
      private$.record_class
    },
    #' @description
    #' Print a `Registry`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A character vector
    print = function(style = TRUE) {
      fields <- self$get_fields()
      # Remove hidden fields
      fields <- fields[grep("^_", names(fields), value = TRUE, invert = TRUE)]
      # Remove link fields
      fields <- fields[grep("^links_", names(fields), value = TRUE, invert = TRUE)]

      relational_fields <- purrr::map(fields, "relation_type") |>
        unlist() |>
        names()

      simple_lines <- purrr::map_chr(
        setdiff(names(fields), relational_fields),
        function(.field) {
          paste0(
            cli::col_blue(paste0("    ", .field)), ": ",
            cli::col_grey(fields[[.field]]$type)
          )
        }
      )

      relational_lines <- purrr::map_chr(relational_fields, function(.field) {
        field_object <- fields[[.field]]
        paste0(
          cli::col_blue(paste0("    ", .field)), ": ",
          cli::col_grey(paste0(
            field_object$related_registry_name,
            " (", field_object$relation_type, ")"
          ))
        )
      })

      lines <- c(
        cli::style_bold(cli::col_green(private$.class_name)),
        cli::style_italic(cli::col_br_magenta("  Simple fields")),
        simple_lines,
        cli::style_italic(cli::col_br_magenta("  Relational fields")),
        relational_lines
      )

      if (isFALSE(style)) {
        lines <- cli::ansi_strip(lines)
      }

      purrr::walk(lines, cli::cat_line)
    },
    #' @description
    #' Create a string representation of a `Registry`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      fields <- self$get_fields()
      # Remove hidden fields
      fields <- fields[grep("^_", names(fields), value = TRUE, invert = TRUE)]
      # Remove link fields
      fields <- fields[grep("^links_", names(fields), value = TRUE, invert = TRUE)]

      relational_fields <- purrr::map(fields, "relation_type") |>
        unlist() |>
        names()

      field_strings <- make_key_value_strings(
        list(
          "SimpleFields" = paste0(
            "[",
            paste(setdiff(names(fields), relational_fields), collapse = ", "),
            "]"
          ),
          "RelationalFields" = paste0(
            "[",
            paste(relational_fields, collapse = ", "),
            "]"
          )
        ),
        quote_strings = FALSE
      )

      make_class_string(private$.class_name, field_strings, style = style)
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
    #' @field module ([Module])\cr
    #' The instance the registry belongs to.
    module = function() {
      private$.module
    },
    #' @field name (`character(1)`)\cr
    #' The API for the instance.
    name = function() {
      private$.registry_name
    },
    #' @field class_name (`character(1)`)\cr
    #' The class name for the registry.
    class_name = function() {
      private$.class_name
    },
    #' @field is_link_table (`logical(1)`)\cr
    #' Whether the registry is a link table.
    is_link_table = function() {
      private$.is_link_table
    }
  )
)
