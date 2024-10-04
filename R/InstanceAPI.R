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
    },
    #' Get the schema for the instance.
    get_schema = function() {
      # TODO: replace with laminr.api get_schema call
      request <- httr::GET(
        paste0(
          private$.instance_settings$api_url,
          "/instances/",
          private$.instance_settings$id,
          "/schema"
        )
      )

      content <- httr::content(request)
      if (httr::http_error(request)) {
        cli_abort(content$detail)
      }

      content
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
      body_data <- list()
      if (!is.null(select)) {
        body_data$select <- select
      }
      body <-
        if (length(body_data) > 0) {
          jsonlite::toJSON(body_data)
        } else {
          "{}"
        }

      url <- paste0(
        private$.instance_settings$api_url,
        "/instances/",
        private$.instance_settings$id,
        "/modules/",
        module_name,
        "/",
        registry_name,
        "/",
        id_or_uid,
        "?schema_id=",
        private$.instance_settings$schema_id,
        "&include_foreign_keys=",
        tolower(include_foreign_keys)
      )

      request <- httr::POST(
        url,
        httr::add_headers(
          accept = "application/json",
          `Content-Type` = "application/json"
        ),
        body = body
      )

      content <- httr::content(request)
      if (httr::http_error(request)) {
        cli_abort(content$detail)
      }

      content
    }
  ),
  private = list(
    .instance_settings = NULL
  )
)
