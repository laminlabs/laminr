#' @importFrom jsonlite toJSON
api_get_record <- function(
    instance_settings,
    module_name,
    model_name,
    id_or_uid,
    select = NULL,
    verbose = FALSE) {
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
        instance_settings$api_url,
        "/instances/",
        instance_settings$id,
        "/modules/",
        module_name,
        "/",
        model_name,
        "/",
        id_or_uid,
        "?schema_id=",
        instance_settings$schema_id
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
