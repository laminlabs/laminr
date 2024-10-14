#' @title InstanceAPI
#'
#' @noRd
#'
#' @description
#' A wrapper around the LaminDB API for an instance.
InstanceAPI <- R6::R6Class( # nolint object_name_linter
  "API",
  cloneable = FALSE,
  public = list(
    #' @param instance_settings The settings for the instance
    #' Should have the following fields:
    #'  - id: The ID of the instance
    #'  - api_url: The URL of the API
    #'  - schema_id: The ID of the schema
    initialize = function(instance_settings) {
      private$.instance_settings <- instance_settings
      private$.api_client <- laminr.api::ApiClient$new(instance_settings$api_url)
      private$.default_api <- laminr.api::DefaultApi$new(private$.api_client)
    },
    #' @description
    #' Get the schema for the instance.
    get_schema = function(id) {
      try(
        private$.default_api$GetSchemaInstancesInstanceIdSchemaGet(
          private$.instance_settings$id
        )
      ) |>
        private$process_response("schema")
    },
    #' @description
    #' Get a record from the instance.
    #'
    #' @importFrom jsonlite toJSON
    get_record = function(module_name,
                          registry_name,
                          id_or_uid,
                          include_foreign_keys = FALSE,
                          select = NULL,
                          verbose = FALSE) {
      if (!is.null(select) && !is.character(select)) {
        cli_abort("select must be a character vector")
      }

      if (verbose) {
        field_name_str <-
          if (!is.null(select)) {
            paste0(", field_name '", select, "'")
          } else {
            ""
          }
        cli_inform(paste0(
          "Getting record from module '", module_name, "', ",
          "registry '", registry_name, "', ",
          "id_or_uid '", id_or_uid, "'",
          field_name_str, "\n"
        ))
      }

      try(
        private$.default_api$GetRecordInstancesInstanceIdModulesModuleNameModelNameIdOrUidPost(
          instance_id = private$.instance_settings$id,
          module_name = module_name,
          model_name = registry_name,
          id_or_uid = id_or_uid,
          schema_id = private$.instance_settings$schema_id,
          include_foreign_keys = tolower(include_foreign_keys),
          get_record_request_body = laminr.api::GetRecordRequestBody$new(select)
        )
      ) |>
        private$process_response("record")
    }
  ),
  private = list(
    .instance_settings = NULL,
    .api_client = NULL,
    .default_api = NULL,
    process_response = function(response, request_type) {
      if (inherits(response, "try-error")) {
        cli::cli_abort(c(
          "Request for {request_type} failed",
          "i" = "Error message: {.code {response[1]}}"
        ))
      }

      return(response)
    },
    #' @description
    #' Print an `API`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    print = function(style = TRUE) {
      cli::cat_line(self$to_string(style))
    },
    #' @description
    #' Create a string representation of an `API`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      field_strings <- make_key_value_strings(
        private$.instance_settings, c("api_url", "id", "schema_id")
      )

      make_class_string("API", field_strings, style = style)
    }
  )
)
