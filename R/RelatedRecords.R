#' @title RelatedRecords
#'
#' @description
#' A container for accessing records with a one-to-many or many-to-many
#' relationship.
RelatedRecords <- R6::R6Class( # nolint object_name_linter
  "RelatedRecords",
  cloneable = FALSE,
  public = list(
    #' @description
    #' Creates an instance of this R6 class. This class should not be instantiated directly,
    #' but rather by connecting to a LaminDB instance using the [connect()] function.
    #'
    #' @param instance The instance the records list belongs to.
    #' @param registry The registry the records list belongs to.
    #' @param field The field associated with the records list.
    #' @param related_to ID or UID of the parent that records are related to.
    #' @param api The API for the instance.
    initialize = function(instance, registry, field, related_to, api) {
      private$.instance <- instance
      private$.registry <- registry
      private$.api <- api
      private$.field <- field
      private$.related_to <- related_to
    },
    #' @description
    #' Get a data frame summarising records in the registry
    #'
    #' @param limit Maximum number of records to return
    #' @param verbose Boolean, whether to print progress messages
    #'
    #' @return A data.frame containing the available records
    df = function(limit = 100, verbose = FALSE) {
      private$get_records(as_df = TRUE)
    },
    #' @description
    #' Print a `RelatedRecords`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    print = function(style = TRUE) {
      cli::cat_line(self$to_string(style))
    },
    #' @description
    #' Create a string representation of a `RelatedRecords`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      fields <- list(
        field_name = private$.field$field_name,
        relation_type = private$.field$relation_type,
        related_to = private$.related_to
      )

      field_strings <- make_key_value_strings(fields)

      make_class_string(
        "RelatedRecords", field_strings,
        style = style
      )
    }
  ),
  active = list(
    #' @field field ([Field])\cr
    #' The field the records are related to.
    field = function() {
      private$.field
    }
  ),
  private = list(
    .instance = NULL,
    .registry = NULL,
    .api = NULL,
    .field = NULL,
    .related_to = NULL,
    get_records = function(as_df = FALSE) {
      field <- private$.field

      # Fetch the field to get the related data
      related_data <- private$.api$get_record(
        module_name = field$module_name,
        registry_name = field$registry_name,
        id_or_uid = private$.related_to,
        select = field$field_name,
        limit_to_many = 100000L # Make this high to get all related records
      )[[field$field_name]]

      if (as_df) {
        values <- related_data |>
          # Replace NULL with NA so columns aren't lost
          purrr::modify_depth(2, \(x) ifelse(is.null(x), NA, x)) |>
          # Convert each entry to a data.frame
          purrr::map(as.data.frame) |>
          # Bind entries as rows
          purrr::list_rbind()
      } else {
        # Get record class for records in the list
        related_module <- private$.instance$get_module(field$related_module_name)
        related_registry <- related_module$get_registry(field$related_registry_name)
        related_registry_class <- related_registry$get_record_class()

        values <- map(related_data, ~ related_registry_class$new(.x))
      }

      return(values)
    }
  )
)
