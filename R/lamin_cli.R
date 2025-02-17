#' Set the default LaminDB instance
#'
#' Set the default LaminDB instance by calling `lamin connect` on the command
#' line
#'
#' @param slug Slug giving the instance to connect to (`<owner>/<name>`)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' lamin_connect("laminlabs/cellxgene")
#' }
lamin_connect <- function(slug) {
  current_default <- getOption("LAMINR_DEFAULT_INSTANCE")
  if (!is.null(current_default)) {
    cli::cli_abort(c(
      "There is already a default instance connected ({.field {current_default}})",
      "x" = "{.code lamin connect} will not be run"
    ))
  }

  # Set the default environment if not set
  reticulate::use_virtualenv("r-lamindb", required = FALSE)
  if (!reticulate::py_available()) {
    # Force reticulate to connect to Python
    py_config <- reticulate::py_config() # nolint object_usage_linter
  }

  system2("lamin", paste("connect", slug))
}

#' Login to LaminDB
#'
#' Login as a LaminDB user
#'
#' @param user Handle for the user to login as
#' @param api_key API key for a user
#'
#' @details
#' Setting `user` will run `lamin login <user>`. Setting `api_key` will set the
#' `LAMIN_API_KEY` environment variable tempoarily with `withr::with_envvar()`
#' and run `lamin login`. If neither `user` or `api_key` are set `lamin login`
#' will be run if `LAMIN_API_KEY` is set.
#'
#' @export
lamin_login <- function(user = NULL, api_key = NULL) {
  current_default <- getOption("LAMINR_DEFAULT_INSTANCE")
  if (!is.null(current_default)) {
    cli::cli_abort(c(
      "There is already a default instance connected ({.field {current_default}})",
      "x" = "{.code lamin login} will not be run"
    ))
  }

  # Set the default environment if not set
  reticulate::use_virtualenv("r-lamindb", required = FALSE)
  if (!reticulate::py_available()) {
    # Force reticulate to connect to Python
    py_config <- reticulate::py_config() # nolint object_usage_linter
  }

  if (!is.null(user)) {
    system2("lamin", paste("login", user))
  } else if (!is.null(api_key)) {
    withr::with_envvar(c("LAMIN_API_KEY" = api_key), {
      system2("lamin", "login")
    })
  } else {
    if (Sys.getenv("LAMIN_API_KEY") == "") {
      cli::cli_abort("{.arg LAMIN_API_KEY} is not set")
    }

    system2("lamin", "login")
  }
}
