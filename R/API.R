API <- R6::R6Class( # nolint object_name_linter
  "API",
  cloneable = FALSE,
  public = list(
    initialize = function(api_url, instance_id, schema_id) {
      private$api_url <- api_url
      private$instance_id <- instance_id
      private$schema_id <- schema_id
    },
    get_schema = function() {
      # TODO: replace with laminr.api get_schema call
      request <- httr::GET(
        paste0(
          private$api_url,
          "/instances/",
          private$instance_id,
          "/schema"
        )
      )

      if (httr::http_error(request)) {
        cli::cli_abort(httr::content(request)$detail)
      }

      httr::content(request)
    },
    #' @importFrom jsonlite toJSON
    get_record = function(
      module_name,
      model_name,
      id_or_uid,
      include_foreign_keys = FALSE,
      select = NULL,
      verbose = FALSE
    ) {
      if (verbose) {
        field_name_str <-
          if (!is.null(select)) {
            paste0(", field_name '", select, "'")
          } else {
            ""
          }
        cli::cli_inform(paste0(
          "Getting record from module '", module_name, "', ",
          "model '", model_name, "', ",
          "id_or_uid '", id_or_uid, "'",
          field_name_str, "\n"
        ))
      }
      body_data <- list()
      if (!is.null(select)) {
        if (!is.character(select)) {
          cli::cli_abort("select must be a character vector")
        }
        body_data$select <- select
      }
      body <-
        if (length(body_data) > 0) {
          jsonlite::toJSON(body_data)
        } else {
          "{}"
        }

      url <- paste0(
        private$api_url,
        "/instances/",
        private$instance_id,
        "/modules/",
        module_name,
        "/",
        model_name,
        "/",
        id_or_uid,
        "?schema_id=",
        private$schema_id,
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

      if (httr::http_error(request)) {
        cli::cli_abort(httr::content(request)$detail)
      }

      httr::content(request)
    }

  ),
  private = list(
    api_url = NULL,
    instance_id = NULL,
    schema_id = NULL
  )
)
