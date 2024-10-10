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
    #' Get the schema for the instance.
    get_schema = function(id) {
      schema <- try(
        private$.default_api$GetSchemaInstancesInstanceIdSchemaGet(
          private$.instance_settings$id
        )
      )

      if (inherits(schema, "try-error")) {
        cli::cli_abort(c(
          "Failed to get schema",
          "i" = "Error message: {.code {schema[1]}}"
        ))
      }

      return(schema)
    },
    #' Get a record from the instance.
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

      if (!is.null(select)) {
        body <- jsonlite::toJSON(list(select = select))
      } else {
        body <- "{}"
      }

      record <- try(
        private$.default_api$GetRecordInstancesInstanceIdModulesModuleNameModelNameIdOrUidPost(
          instance_id = private$.instance_settings$id,
          module_name = module_name,
          model_name = registry_name,
          id_or_uid = id_or_uid,
          schema_id = private$.instance_settings$schema_id,
          include_foreign_keys = tolower(include_foreign_keys),
          get_record_request_body = body
        )
      )

      if (inherits(record, "try-error")) {
        cli::cli_abort(c(
          "Failed to get schema",
          "i" = "Error message: {.code {record[1]}}"
        ))
      }

      return(record)
    }
  ),
  private = list(
    .instance_settings = NULL,
    .api_client = NULL,
    .default_api = NULL
  )
)
