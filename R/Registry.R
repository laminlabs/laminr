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
    #' Get a data frame summarising records in the registry
    #'
    #' @param limit Maximum number of records to return
    #' @param verbose Boolean, whether to print progress messages
    #'
    #' @return A data.frame containing the available records
    #' @importFrom purrr reduce modify_depth
    df = function(limit = 100, verbose = FALSE) {
      # The API is limited to 200 records at a time so we need multiple requests
      n_requests <- ceiling(limit / 200)
      if ((verbose && n_requests > 1) || n_requests >= 10) {
        caution <- ifelse(n_requests >= 10, "CAUTION: ", "")
        cli::cli_alert_warning(
          "{caution}Retrieving {limit} records will require up to {n_requests} API requests"
        )
      }

      data_list <- list()
      attr(data_list, "finished") <- FALSE
      data_list <- reduce(
        cli::cli_progress_along(seq_len(n_requests), name = "Sending requests"),
        \(.data_list, .n) {
          # Hacky way of avoiding unneeded requests until there is an easy way
          # to get the total number of records
          if (isTRUE(attr(.data_list, "finished"))) {
            return(.data_list)
          }

          offset <- (.n - 1) * 200
          # Reduce limit for final request to get the correct total
          current_limit <- ifelse(.n == n_requests, limit %% 200, 200)
          if (verbose) {
            cli::cli_alert_info(
              "Requesting records {offset} to {offset + current_limit}..."
            )
          }
          current_data <- private$.api$get_records(
            module_name = private$.module$name,
            registry_name = private$.registry_name,
            limit = current_limit,
            offset = offset,
            verbose = verbose
          )

          .data_list <- c(.data_list, current_data)
          # If not the final request and less than 200 records returned then
          # there are no more records and we can skip remaining requests
          if ((.n != n_requests) && length(.data_list) < 200) {
            cli::cli_alert_info(paste(
              "Found all records. Stopping early with {length(.data_list)}",
              "record{?s} after {(.n)} request{?s}."
            ))
            attr(.data_list, "finished") <- TRUE
          }

          return(.data_list)
        },
        .init = data_list
      )

      data_list |>
        # Replace NULL with NA so columns aren't lost
        modify_depth(2, \(x) ifelse(is.null(x), NA, x)) |>
        # Convert each entry to a data.frame
        map(as.data.frame) |>
        # Bind entries as rows
        list_rbind()
    },
    #' @description
    #' Create a record from a data frame
    #'
    #' @param dataframe The `data.frame` to create a record from
    #' @param key A relative path within the default storage
    #' @param description A string describing the record
    #' @param run A `Run` object that creates the record
    #'
    #' @details
    #' Creating records is only possible for the default instance, requires the
    #' Python `lamindb` module and is only implemented for the core `Artifact`
    #' registry.
    #'
    #' @return A `TemporaryRecord` object containing the new record. This is not
    #' saved to the database until `temp_record$save()` is called.
    from_df = function(dataframe, key = NULL, description = NULL, run = NULL) {
      if (isFALSE(private$.instance$is_default)) {
        cli::cli_abort(c(
          "Only the default instance can create records",
          "i" = "Use {.code connect(slug = NULL)} to connect to the default instance"
        ))
      }

      if (is.null(private$.instance$py_lamin)) {
        cli::cli_abort(c(
          "Creating records requires the Python lamindb package",
          "i" = "Check the output of {.code connect()} for warnings"
        ))
      }

      if (private$.registry_name != "artifact") {
        cli::cli_abort(
          "Creating records from data frames is only supported for the Artifact registry"
        )
      }

      py_lamin <- private$.instance$py_lamin

      py_record <- py_lamin$Artifact$from_df(
        dataframe,
        key = key, description = description, run = run
      )

      create_record_from_python(py_record, private$.instance)
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
    #' Get the temporary record class for the registry.
    #'
    #' Note: This method is intended for internal use only and may be removed in the future.
    #'
    #' @return A `TemporaryRecord` class.
    get_temporary_record_class = function() {
      if (is.null(private$.temporary_record_class)) {
        private$.temporary_record_class <- create_temporary_record_class(
          private$.record_class
        )
      }

      private$.temporary_record_class
    },
    #' @description
    #' Print a `Registry`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A character vector
    print = function(style = TRUE) {
      # Get fields
      fields <- self$get_fields() |>
        # Remove hidden fields
        discard(~ grepl("^_", .x$field_name)) |>
        # Remove link fields
        discard(~ grepl("^links_", .x$field_name))

      # Split fields into simple and relational
      simple_fields <- fields |>
        keep(~ is.null(.x$relation_type))
      relational_fields <- fields |>
        discard(~ is.null(.x$relation_type))

      # Create lines for simple fields
      simple_lines <-
        if (length(simple_fields) > 0) {
          c(
            cli::style_italic(cli::col_br_magenta("  Simple fields")),
            map_chr(simple_fields, ~ paste0("    ", .x$field_name, ": ", .x$type))
          )
        } else {
          character(0)
        }

      # Check which modules need to be displayed, make sure "core" is always first
      relational_field_modules <- map_chr(relational_fields, "related_module_name")
      related_modules <- unique(relational_field_modules)
      related_modules <- related_modules[order(related_modules != "core", related_modules)]

      # Create lines for relational fields
      relational_lines <- map(related_modules, function(related_module_name) {
        # get heading for module
        module_heading <-
          if (related_module_name == "core") {
            "Relational fields"
          } else {
            paste(tools::toTitleCase(related_module_name), "fields")
          }

        # iterate over fields
        module_fields <- relational_fields[relational_field_modules == related_module_name]
        related_module <- private$.instance$get_module(related_module_name)
        module_lines <- map_chr(module_fields, function(field) {
          module_prefix <- ifelse(related_module_name == "core", "", paste0(related_module_name, "$"))
          related_registry <- related_module$get_registry(field$related_registry_name)
          paste0(
            "    ", field$field_name, ": ", module_prefix, related_registry$class_name,
            cli::col_grey(paste0(" (", field$relation_type, ")"))
          )
        })

        # return lines
        c(
          cli::style_italic(cli::col_br_magenta(paste0("  ", module_heading))),
          module_lines
        )
      }) |>
        list_c()

      lines <- c(
        cli::style_bold(cli::col_br_green(private$.class_name)),
        simple_lines,
        relational_lines
      )

      if (isFALSE(style)) {
        lines <- cli::ansi_strip(lines)
      }

      walk(lines, cli::cat_line)
    },
    #' @description
    #' Create a string representation of a `Registry`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      # Get fields
      fields <- self$get_fields() |>
        # Remove hidden fields
        discard(~ grepl("^_", .x$field_name)) |>
        # Remove link fields
        discard(~ grepl("^links_", .x$field_name))

      # Split fields into simple and relational
      simple_fields <- fields |>
        keep(~ is.null(.x$relation_type))
      relational_fields <- fields |>
        discard(~ is.null(.x$relation_type))

      # Create strings for simple fields
      simple_strings <- make_key_value_strings(
        list(
          "SimpleFields" = paste0(
            "[",
            paste(map_chr(simple_fields, "field_name"), collapse = ", "),
            "]"
          )
        ),
        quote_strings = FALSE
      )

      # Check which modules need to be displayed, make sure "core" is always first
      relational_field_modules <- map_chr(relational_fields, "related_module_name")
      related_modules <- unique(relational_field_modules)
      related_modules <- related_modules[order(related_modules != "core", related_modules)]

      # Create strings for relational fields
      relational_strings <- map_chr(related_modules, function(related_module_name) {
        # get heading for module
        module_heading <-
          if (related_module_name == "core") {
            "RelationalFields"
          } else {
            paste0(tools::toTitleCase(related_module_name), "Fields")
          }

        # iterate over fields
        module_fields <- relational_fields[relational_field_modules == related_module_name]

        list(
          paste0("[", paste(map_chr(module_fields, "field_name"), collapse = ", "), "]")
        ) |>
          set_names(module_heading) |>
          make_key_value_strings(quote_strings = FALSE)
      })

      field_strings <- c(
        simple_strings,
        relational_strings
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
    .record_class = NULL,
    .temporary_record_class = NULL
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

#' Create record from Python
#'
#' @param py_record A Python record object
#' @param instance `Instance` object to create the record for
#'
#' @details
#' The new record is created by:
#'
#' 1. Getting the module and registry from the Python class
#' 2. Getting the fields for this registry
#' 3. Iteratively getting the data for each field. Values that are records are
#'    converted by calling this function.
#' 4. Get the matching temporary record class
#' 5. Return the temporary record
#'
#' @return The created `TemporaryRecord` object
#' @noRd
create_record_from_python <- function(py_record, instance) {
  py_classes <- class(py_record)

  # Skip related fields for now
  if ("django.db.models.manager.Manager" %in% py_classes) {
    return(NULL)
  }

  class_split <- strsplit(py_classes[1], "\\.")[[1]]
  module_name <- class_split[1]
  if (module_name == "lnschema_core") {
    module_name <- "core"
  }
  registry_name <- tolower(class_split[3])

  registry <- instance$get_module(module_name)$get_registry(registry_name)
  fields <- registry$get_field_names()

  record_list <- map(fields, function(.field) {
    value <- tryCatch(
      py_record[[.field]],
      error = function(err) {
        NULL
      }
    )
    if (inherits(value, "lnschema_core.models.Record")) {
      value <- create_record_from_python(value, instance)
    }
    value
  }) |>
    set_names(fields)

  temp_record_class <- registry$get_temporary_record_class()

  # Suppress warnings because we deliberately add unexpected data fields
  suppressWarnings(temp_record_class$new(py_record, record_list))
}
