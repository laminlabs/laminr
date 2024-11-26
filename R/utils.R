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
check_requires <- function(what, requires,
                           alert = c("error", "warning", "message", "none"),
                           extra_repos = NULL) {
  alert <- match.arg(alert)

  is_available <- map_lgl(requires, requireNamespace, quietly = TRUE)

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
is_knitr_notebook <- function() {
  # if knitr is not available, assume that we are not in a notebook
  if (!requireNamespace("knitr", quietly = TRUE)) {
    return(FALSE)
  }

  # check if we are in a notebook
  !is.null(knitr::opts_knit$get("out.format"))
}
