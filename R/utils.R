#' Check required packages
#'
#' Check that required packages are available and give a nice message with
#' install instructions if not
#'
#' @param what A message stating what the packages are required for. Used at the
#'   start of the error message e.g. "{what} requires...".
#' @param requires Character vector of required package names
#' @param type Type of message to give if packages are missing
#'
#' @return Invisibly, Boolean whether or not all packages are available or
#'   raises an error if any are missing and `type = "error"`
#' @noRd
check_requires <- function(what, requires, type = c("error", "warning")) {
  type <- match.arg(type)

  is_available <- map_lgl(requires, requireNamespace, quietly = TRUE)

  msg_fun <- switch(type,
    error = cli::cli_abort,
    warning = cli::cli_warn
  )

  if (any(!is_available)) {
    missing <- requires[!is_available]
    missing_str <- paste0("'", paste(missing, collapse = "', '"), "'") # nolint object_usage_linter
    msg_fun(
      c(
        "{what} requires the {.pkg {missing}} package{?s}",
        "i" = paste(
          "Install {cli::qty(missing)}{?it/them} using",
          "{.run install.packages(c({missing_str}))}"
        )
      ),
      call = rlang::caller_env()
    )
  }

  invisible(all(is_available))
}

#' Check if we are in a knitr notebook
#'
#' @return `TRUE` if we are in a knitr notebook, `FALSE` otherwise
#'
#' @noRd
is_knitr_notebook <- function() {
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
detect_path <- function() {
  # Based on various responses from https://stackoverflow.com/questions/47044068/get-the-path-of-current-script

  current_path <- NULL

  # Get path if in a running RMarkdown notebook
  if (is_knitr_notebook()) {
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
  if (is.null(current_path) &&
      requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    doc_context <- rstudioapi::getActiveDocumentContext()
    if (doc_context$id != "#console") {
      current_path <- doc_context$path
    }
  }

  # Normalise the path relative to the working directory
  if (!is.null(current_path)) {
    current_path <- R.utils::getRelativePath(current_path)
  }

  return(current_path)
}
