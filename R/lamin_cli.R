#' Set the default LaminDB instance
#'
#' Set the default LaminDB instance by calling `lamin connect` on the command
#' line
#'
#' @param instance Either a slug giving the instance to connect to
#' (`<owner>/<name>`) or an instance URL (`https://lamin.ai/owner/name`)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' lamin_connect("laminlabs/cellxgene")
#' }
lamin_connect <- function(instance) {
  current_default <- getOption("LAMINR_DEFAULT_INSTANCE")
  if (!is.null(current_default)) {
    cli::cli_abort(c(
      "There is already a default instance connected ({.val {current_default}})",
      "x" = "{.code lamin connect} will not be run",
      "i" = "Start a new R session to connect to another instance"
    ))
  }

  # Set the default environment if not set
  reticulate::use_virtualenv("r-lamindb", required = FALSE)
  if (!reticulate::py_available()) {
    # Force reticulate to connect to Python
    py_config <- reticulate::py_config() # nolint object_usage_linter
  }

  system2("lamin", paste("connect", instance))
}

#' Log into LaminDB
#'
#' Log in as a LaminDB user
#'
#' @param user Handle for the user to login as
#' @param api_key API key for a user
#'
#' @details
#' Depending on the input, one of these commands will be run (in this order):
#'
#' 1. If `user` is set then `lamin login <user>`
#' 2. Else if `api_key` is set then set the `LAMIN_API_KEY` environment variable
#' temporarily with `withr::with_envvar()` and run `lamin login`
#' 3. Else if there is a stored user handle run `lamin login <handle>`
#' 4. Else if the `LAMIN_API_KEY` environment variable is set run `lamin login`
#'
#' Otherwise, exit with an error
#'
#' @export
lamin_login <- function(user = NULL, api_key = NULL) {
  current_default <- getOption("LAMINR_DEFAULT_INSTANCE")
  if (!is.null(current_default)) {
    cli::cli_abort(c(
      "There is already a default instance connected ({.val {current_default}})",
      "x" = "{.code lamin login} will not be run",
      "i" = "Start a new R session before attempting to log in"
    ))
  }

  reticulate::use_virtualenv("r-lamindb", required = FALSE)
  ln <- reticulate::import("lamindb")
  handle <- ln$setup$settings$user$handle

  if (!is.null(user)) {
    # If user is provided run `lamin login <user>`
    cli::cli_alert_info("Using provided user {.val {user}}")
    system2("lamin", paste("login", user))
  } else if (!is.null(api_key)) {
    # If api_key is provided, run `lamin login` with the LAMIN_API_KEY env var
    cli::cli_alert_info("Using provided API key")
    withr::with_envvar(c("LAMIN_API_KEY" = api_key), {
      system2("lamin", "login")
    })
  } else if (!is.null(handle) && handle != "anonymous") {
    # If there is a stored user handle run `lamin login <handle>`
    cli::cli_alert_info("Using stored user handle {.val {handle}}")
    system2("lamin", paste("login", handle))
  } else if (Sys.getenv("LAMIN_API_KEY") != "") {
    # If the LAMIN_API_KEY env var is already set run `lamin login`
    cli::cli_alert_info("Using {.field LAMIN_API_KEY} environment variable")
    system2("lamin", "login")
  } else {
    # Fail to log in
    cli::cli_abort(
      "Unable to log in. Please provide {.arg user} or {.arg api_key}."
    )
  }
}

#' Log out of LaminDB
#'
#' Log out of LaminDB
#'
#' @export
lamin_logout <- function() {
  current_default <- getOption("LAMINR_DEFAULT_INSTANCE")
  if (!is.null(current_default)) {
    cli::cli_abort(c(
      "There is already a default instance connected ({.val {current_default}})",
      "x" = "{.code lamin logout} will not be run",
      "i" = "Start a new R session before attempting to log out"
    ))
  }

  # Set the default environment if not set
  reticulate::use_virtualenv("r-lamindb", required = FALSE)
  if (!reticulate::py_available()) {
    # Force reticulate to connect to Python
    py_config <- reticulate::py_config() # nolint object_usage_linter
  }

  system2("lamin", "logout")
}

#' Initalise LaminDB
#'
#' Initialise a new LaminDB instance
#'
#' @param storage A local directory, AWS S3 bucket or Google Cloud Storage bucket
#' @param name A name for the instance
#' @param db A Postgres database connection URL, use `NULL` for SQLite.
#' @param modules A vector of modules to include (e.g. "bionty")
#'
#' @export
#'
#' @examples
#' \dontrun{
#' lamin_init("mydata", modules = c("bionty", "wetlab"))
#' }
lamin_init <- function(storage, name = NULL, db = NULL, modules = NULL) {
  # Set the default environment if not set
  reticulate::use_virtualenv("r-lamindb", required = FALSE)
  if (!reticulate::py_available()) {
    # Force reticulate to connect to Python
    py_config <- reticulate::py_config() # nolint object_usage_linter
  }

  if (!is.null(modules)) {
    check_requires(
      "Initalising a database with these modules", modules, language = "Python"
    )
  }

  options_string <- paste("init --storage", storage)

  if (!is.null(name)) {
    options_string <- c(options_string, paste("--name", name))
  }

  if (!is.null(db)) {
    options_string <- c(options_string, paste("--db", name))
  }

  if (!is.null(modules)) {
    options_string <- c(
      options_string, paste("--modules", paste(modules, collapse = ","))
    )
  }

  system2("lamin", options_string)
}
