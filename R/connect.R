# https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/_connect_instance.py
# NOTE: These functions could be moved to a separate lamindb.setup package

#' Connect to instance
#'
#' @param slug The instance slug `account_handle/instance_name` or URL.
#'   If the instance is owned by you, it suffices to pass the instance name.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # first run 'lamin login' to authenticate
#' instance <- connect("laminlabs/cellxgene")
#' instance
#' }
connect <- function(slug) {
  user_settings <- .settings_load__load_or_create_user_settings()

  owner_name <- .connect_get_owner_name_from_identifier(slug)

  instance_settings <- .connect_get_instance_settings(
    owner = owner_name$owner,
    name = owner_name$name,
    access_token = user_settings$access_token
  )

  create_instance(instance_settings = instance_settings)
}

# nolint start: object_length_linter
.connect_get_owner_name_from_identifier <- function(
    # nolint end: object_length_linter
    identifier) {
  if (grepl("/", identifier)) {
    if (grepl("https://lamin.ai/", identifier)) {
      identifier <- gsub("https://lamin.ai/", "", identifier)
    }
    split <- strsplit(identifier, "/")[[1]]
    if (length(split) > 2) {
      cli_abort(paste0(
        "The instance identifier needs to be 'owner/name', the instance name",
        " (owner is current user) or the URL: https://lamin.ai/owner/name."
      ))
    }
    owner <- split[[1]]
    name <- split[[2]]
  } else {
    user_settings <- .settings_load__load_or_create_user_settings()

    owner <- user_settings$handle
    name <- identifier
  }
  return(list(owner = owner, name = name))
}


.connect_get_instance_settings <- function(owner, name, access_token) { # nolint object_length_linter
  supabase_url <- "https://hub.lamin.ai"
  function_name <- "get-instance-settings-v1"

  body_data <- list(owner = owner, name = name)
  body <-
    if (length(body_data) > 0) {
      jsonlite::toJSON(body_data)
    } else {
      "{}"
    }

  url <- paste0(
    supabase_url,
    "/functions/v1/",
    function_name
  )

  request <- httr::POST(
    url,
    httr::add_headers(
      Authorization = paste0("Bearer ", access_token),
      `Content-Type` = "application/json"
    ),
    body = body
  )
  content <- httr::content(request)

  if (httr::http_error(request)) {
    cli_abort(content)
  }
  if (length(content) == 0) {
    cli_abort(paste0("Instance '", owner, "/", name, "' not found"))
  }

  InstanceSettings$new(content)
}
