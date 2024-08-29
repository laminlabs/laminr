# https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/_connect_instance.py

#' Connect to a Lamin instance
#'
#' Connect to a Lamin instance using the current instance settings.
#'
#' @param slug The slug of the instance to connect to. If not provided, the current instance is used.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' options(
#'   lamindb_current_instance = list(
#'     owner = "lamin",
#'     name = "example",
#'     api_url = "https://us-west-2.api.lamin.ai",
#'     id = "0123456789abcdefghijklmnopqrstuv",
#'     schema_id = "0123456789abcdefghijklmnopqrstuv"
#'   )
#' )
#' db <- connect()
#' }
connect <- function(slug = NULL) {
  if (!is.null(slug)) {
    cli::cli_warn(paste0(
      "Connecting to a specific instance by slug is not yet implemented, ",
      "connecting to the current instance instead"
    ))
  }

  expected_format_str <- paste0(
    "Please set the current instance manually using:\n",
    "  options(lamindb_current_instance = list(url = ..., instance_id = ..., schema_id = ...))"
  )

  current_instance <- getOption("lamindb_current_instance")
  if (is.null(current_instance)) {
    cli::cli_abort(paste0(
      "Parsing ~/.lamin/*.env files is currently not implemented. ",
      expected_format_str
    ))
  }
  if (!is.list(current_instance)) {
    cli::cli_abort(paste0(
      "Expected option 'lamindb_current_instance' to be a list. ",
      expected_format_str
    ))
  }
  for (key in c("owner", "name", "api_url", "id", "schema_id")) {
    if (!key %in% names(current_instance)) {
      cli::cli_abort(paste0(
        "Expected option 'lamindb_current_instance' to have a '",
        key, "' key. ", expected_format_str
      ))
    }
  }

  # TODO: replace with 'setup_instance_from_store'
  create_instance_class(current_instance)
}