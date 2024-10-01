connect <- function(owner, name, access_token = NULL) {
  if (is.null(access_token)) {
    access_token <- .connect_get_access_token()
  }

  settings <- .connect_get_instance_settings(owner, name, access_token)

  create_instance(settings = settings)
}

.connect_get_access_token <- function() {
  requireNamespace("reticulate", quietly = TRUE)
  if (!reticulate::py_module_available("lamindb_setup")) {
    cli::cli_abort("Python module 'lamindb_setup' is required to get the access token")
  }
  ln_setup <- reticulate::import("lamindb_setup")
  ln_setup$settings$user$access_token
}

.connect_get_instance_settings <- function(owner, name, access_token) {
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
    cli::cli_abort(content)
  }
  if (length(content) == 0) {
    cli::cli_abort(paste0("Instance '", owner, "/", name, "' not found"))
  }

  do.call(InstanceSettings$new, content)
}