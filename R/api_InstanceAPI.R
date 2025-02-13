#' @title APIInstanceAPI
#'
#' @noRd
#'
#' @description
#' A wrapper around the LaminDB API for an instance.
APIInstanceAPI <- R6::R6Class( # nolint object_name_linter
  "API",
  cloneable = FALSE,
  public = list(
    #' @description
    #' Creates an instance of this R6 class. This class should not be instantiated directly,
    #' but rather by connecting to a LaminDB instance using the [api_connect()] function.
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

      response <- httr::GET(
        url,
        httr::add_headers(.headers = private$get_headers())
      )

      api_process_httr_response(response, "get schema from instance")
    },
    #' @description
    #' Get a record from the instance.
    get_record = function(module_name,
                          registry_name,
                          id_or_uid,
                          limit_to_many = 10,
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
        httr::add_headers(.headers = private$get_headers()),
        body = body
      )

      api_process_httr_response(response, "get record from instance")
    },
    #' @description
    #' Get a summary of available records from the instance.
    #'
    #' @param module_name Name of the module to query, e.g. "core"
    #' @param registry_name Name of the registry to query
    #' @param limit Maximum number of records to return
    #' @param offset Offset for the first returned record
    #' @param limit_to_many Maximum number of related foreign fields to return
    #' @param include_foreign_keys Boolean, whether to return foreign keys
    #' @param search Search string included in the query body
    #' @param verbose Boolean, whether to print progress messages
    #'
    #' @return Content of the API response, if successful a list of record
    #' summaries
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
        httr::add_headers(.headers = private$get_headers()),
        body = body
      )

      api_process_httr_response(response, "get record from instance")
    },
    #' @description
    #' Delete a record from the instance.
    delete_record = function(module_name,
                             registry_name,
                             id_or_uid,
                             verbose = FALSE) {
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
        private$.instance_settings$schema_id
      )

      if (verbose) {
        cli_inform("URL: {url}")
      }

      response <- httr::DELETE(
        url,
        httr::add_headers(
          .headers = private$get_headers(authorization_required = TRUE)
        )
      )

      api_process_httr_response(response, "delete record from instance")
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
    get_headers = function(authorization_required = FALSE) {
      headers <- c(
        accept = "application/json",
        `Content-Type` = "application/json"
      )
      user_settings <- .api_get_user_settings()

      if (!is.null(user_settings$access_token)) {
        headers[["Authorization"]] <- paste("Bearer", user_settings$access_token)
      } else if (authorization_required) {
        cli::cli_abort(c(
          "There is no access token for the current user",
          "i" = "Run {.code lamin login} and reconnect to the database in a new R session"
        ))
      }

      return(headers)
    }
  )
)
