#' Check required packages
#'
#' Check that required packages are available and give a nice message with
#' install instructions if not
#'
#' @param what A message stating what the packages are required for. Used at the
#'   start of the error message e.g. "{what} requires...".
#' @param requires Character vector of required package names
#' @param alert Type of message to give if packages are missing
#' @param extra_repos Additional repositories that are required to install the
#'   checked packages
#'
#' @return Invisibly, Boolean whether or not all packages are available or
#'   raises an error if any are missing and `type = "error"`
#' @noRd
api_check_requires <- function(what, requires,
                               alert = c("error", "warning", "message", "none"),
                               extra_repos = NULL) {
  alert <- match.arg(alert)

  is_available <- purrr::map_lgl(requires, requireNamespace, quietly = TRUE)

  msg_fun <- switch(alert,
    error = cli::cli_abort,
    warning = cli::cli_warn,
    message = cli::cli_inform,
    none = NULL
  )

  if (!any(is_available) && !is.null(msg_fun)) {
    missing <- requires[!is_available]
    missing_str <- paste0("'", paste(missing, collapse = "', '"), "'") # nolint object_usage_linter

    msg <- "{what} requires the {.pkg {missing}} package{?s}"

    if (!is.null(extra_repos)) {
      msg <- c(
        msg,
        "i" = paste0(
          "Add repositories using {.run options(repos = c(",
          paste0("'", paste(extra_repos, collapse = "', '"), "'"),
          ", getOption('repos'))}, then:"
        )
      )
    }

    msg <- c(
      msg,
      "i" = paste(
        "Install {cli::qty(missing)}{?it/them} using",
        "{.run install.packages(c({missing_str}))}"
      )
    )

    msg_fun(msg, call = rlang::caller_env())
  }

  invisible(any(is_available))
}

#' Check if we are in a knitr notebook
#'
#' @return `TRUE` if we are in a knitr notebook, `FALSE` otherwise
#'
#' @noRd
api_is_knitr_notebook <- function() {
  # if knitr is not available, assume that we are not in a notebook
  if (!requireNamespace("knitr", quietly = TRUE)) {
    return(FALSE)
  }

  # check if we are in a notebook
  !is.null(knitr::opts_knit$get("out.format"))
}

#' Detect path
#'
#' Find the path of the file where code is currently been run
#'
#' @return If found, path to the file relative to the working directory,
#'   otherwise `NULL`
#' @noRd
api_detect_path <- function() {
  # Based on various responses from https://stackoverflow.com/questions/47044068/get-the-path-of-current-script

  current_path <- NULL

  # Get path if in a running RMarkdown notebook
  if (api_is_knitr_notebook()) {
    current_path <- knitr::current_input()
  }

  # Get path if in a script run by `source("script.R")`
  source_trace <- R.utils::findSourceTraceback()
  if (is.null(current_path) && length(source_trace) > 0) {
    current_path <- names(source_trace)[1]
  }

  # Get path if in a script run by `Rscript script.R`
  if (is.null(current_path)) {
    cmd_args <- R.utils::commandArgs(asValues = TRUE)
    current_path <- cmd_args[["file"]]
  }

  # Get path if in a document in RStudio
  if (
    is.null(current_path) &&
      requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()
  ) {
    doc_context <- rstudioapi::getActiveDocumentContext()
    if (doc_context$id != "#console") {
      current_path <- doc_context$path
    }
  }

  # Normalise the path relative to the working directory
  if (!is.null(current_path)) {
    current_path <- R.utils::getRelativePath(current_path)
  }

  current_path
}

#' Resolve an httr response with error handling
#'
#' @param response An httr response object
#' @param request_type A string describing the request type
#'
#' @return The content of the response if successful
#' @noRd
api_process_httr_response <- function(response, request_type) {
  content <- httr::content(response)
  if (httr::http_error(response)) {
    if (is.list(content) && "detail" %in% names(content)) {
      detail <- content$detail
      if (is.list(detail)) {
        detail <- jsonlite::minify(jsonlite::toJSON(content$detail))
      }
    } else {
      detail <- content
    }
    cli_abort(c(
      "Failed to {request_type} with status code {response$status_code}",
      "i" = "Details: {detail}"
    ))
  }

  content
}
