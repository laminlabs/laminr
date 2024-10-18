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
    #' @description
    #' Creates an instance of this R6 class. This class should not be instantiated directly,
    #' but rather by connecting to a LaminDB instance using the [connect()] function.
    #'
    #' @param instance_settings The settings for the instance
    #' Should have the following fields:
    #'  - id: The ID of the instance
    #'  - api_url: The URL of the API
    #'  - schema_id: The ID of the schema
    initialize = function(instance_settings) {
      private$.instance_settings <- instance_settings
    },
    #' @description
    #' Get the schema for the instance.
    get_schema = function() {
      # TODO: replace with laminr.api get_schema call
      url <- paste0(
        private$.instance_settings$api_url,
        "/instances/",
        private$.instance_settings$id,
        "/schema"
      )

      response <- httr::GET(url)

      private$process_response(response, "get schema")
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

      if (verbose) {
        cli_inform("URL: {url}")
        cli_inform("Body: {jsonlite::minify(body)}")
      }

      response <- httr::POST(
        url,
        httr::add_headers(
          accept = "application/json",
          `Content-Type` = "application/json"
        ),
        body = body
      )

      private$process_response(response, "get record")
    },
    #' @description
    #' Get a summary of available records from the instance.
    #'
    #' @param module_name Name of the module to query, e.g. "core"
    #' @param registry_name Name of the registry to query
    #' @param limit Maximum number of records to return
    #' @param offset Offset for the first returned record
    #' @param limit_to_many
    #' @param include_foreign_keys Boolean, whether to return foreign keys
    #' @param search Search string included in the query body
    #' @param verbose Boolean, whether to print progress messages
    #'
    #' @return Content of the API response
    #'
    #' @importFrom jsonlite toJSON
    get_records = function(module_name,
                           registry_name,
                           limit = 50,
                           offset = 0,
                           limit_to_many = 10,
                           include_foreign_keys = FALSE,
                           search = NULL,
                           verbose = FALSE) {
      if (!is.null(search) && !is.character(search)) {
        cli_abort("search must be a character vector")
      }

      if (limit > 200) {
        cli::cli_abort("This API call is limited to 200 results per call")
      }

      if (verbose) {
        cli_inform(c(
          paste0(
            "Getting records from module '", module_name, "', ",
            "registry '", registry_name, "' with the following arguments:"
          ),
          " " = "limit: {limit}",
          " " = "offset: {offset}",
          " " = "limit_to_many: {limit_to_many}",
          " " = "include_foreign_keys: {include_foreign_keys}",
          " " = "search: '{search}'"
        ))
      }

      body_data <- list(search = jsonlite::unbox(""))
      if (!is.null(search)) {
        body_data$search <- jsonlite::unbox(search)
      }
      body <- jsonlite::toJSON(body_data)

      url <- paste0(
        private$.instance_settings$api_url,
        "/instances/",
        private$.instance_settings$id,
        "/modules/",
        module_name,
        "/",
        registry_name,
        "?schema_id=",
        private$.instance_settings$schema_id,
        "&limit=",
        limit,
        "&offset=",
        offset,
        "&limit_to_many=",
        limit_to_many,
        "&include_foreign_keys=",
        tolower(include_foreign_keys)
      )

      if (verbose) {
        cli_inform("URL: {url}")
        cli_inform("Body: {jsonlite::minify(body)}")
      }

      response <- httr::POST(
        url,
        httr::add_headers(
          accept = "application/json",
          `Content-Type` = "application/json"
        ),
        body = body
      )

      private$process_response(response, "get record")
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
  ),
  private = list(
    .instance_settings = NULL,
    process_response = function(response, request_type) {
      content <- httr::content(response)
      if (httr::http_error(response)) {
        if (is.list(content) && "detail" %in% names(content)) {
          cli_abort(content$detail)
        } else {
          cli_abort("Failed to {request_type} from instance. Output: {content}")
        }
      }

      content
    }
  )
)
