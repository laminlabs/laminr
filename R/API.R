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
      httr::GET(
        paste0(
          private$api_url,
          "/instances/",
          private$instance_id,
          "/schema"
        )
      ) |>
        httr::content()
    },
    #' @importFrom jsonlite toJSON
    api_get_record = function(
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

      data <-
        httr::POST(
          paste0(
            private$api_url,
            "/instances/",
            private$id,
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
          ),
          httr::add_headers(
            accept = "application/json",
            `Content-Type` = "application/json"
          ),
          body = body
        ) |>
        httr::content()

      data
    }

  ),
  private = list(
    api_url = NULL,
    instance_id = NULL,
    schema_id = NULL
  )
)
