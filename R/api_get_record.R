#' @importFrom jsonlite toJSON
api_get_record <- function(
    api,
    instance_settings,
    module_name,
    model_name,
    id_or_uid,
    include_foreign_keys = FALSE,
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

  operations <- rapiclient::get_operations(api)

  operations$get_record_instances__instance_id__modules__module_name___model_name___id_or_uid__post(
    instance_id = instance_settings$id,
    module_name = module_name,
    model_name = model_name,
    id_or_uid = id_or_uid,
    schema_id = instance_settings$schema_id,
    include_foreign_keys = tolower(include_foreign_keys),
    .__body__ = body
  ) |>
    httr::content()

  # data <-
  #   httr::POST(
  #     paste0(
  #       instance_settings$api_url,
  #       "/instances/",
  #       instance_settings$id,
  #       "/modules/",
  #       module_name,
  #       "/",
  #       model_name,
  #       "/",
  #       id_or_uid,
  #       "?schema_id=",
  #       instance_settings$schema_id,
  #       "&include_foreign_keys=",
  #       tolower(include_foreign_keys)
  #     ),
  #     httr::add_headers(
  #       accept = "application/json",
  #       `Content-Type` = "application/json"
  #     ),
  #     body = body
  #   ) |>
  #   httr::content()
  #
  # data
}
