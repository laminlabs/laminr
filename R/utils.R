#' Check required packages
#'
#' Check that required packages are available and give a nice message with
#' install instructions if not
#'
#' @param what A message stating what the packages are required for. Used at the
#'   start of the error message e.g. "{what} requires...".
#' @param requires Character vector of required package names
#' @param alert Type of message to give if packages are missing
#' @param language The language to check if the package exists, either "R" or
#'   "Python"
#' @param extra_repos Additional repositories that are required to install the
#'   checked packages (only for R)
#' @param check_fun The
#'
#' @return Invisibly, Boolean whether or not all packages are available or
#'   raises an error if any are missing and `type = "error"`
#' @noRd
check_requires <- function(what, requires,
                           alert = c("error", "warning", "message", "none"),
                           language = c("R", "Python"), extra_repos = NULL) {
  alert <- match.arg(alert)
  language <- match.arg(language)

  is_available <- if (language == "R") {
    purrr::map_lgl(requires, requireNamespace, quietly = TRUE)
  } else {
    purrr::map_lgl(requires, reticulate::py_module_available)
  }

  msg_fun <- switch(alert,
                    error = cli::cli_abort,
                    warning = cli::cli_warn,
                    message = cli::cli_inform,
                    none = NULL
  )

  if (!all(is_available) && !is.null(msg_fun)) {
    missing <- requires[!is_available]
    missing_str <- paste0("'", paste(missing, collapse = "', '"), "'") # nolint object_usage_linter

    msg <- "{what} requires the {language} {.pkg {missing}} package{?s}"

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

    install_msg <- if (language == "R") {
      "{.run install.packages(c({missing_str}))}"
    } else {
      "{.run install_lamindb(extra_packages = c({missing_str}))}"
    }

    msg <- c(
      msg,
      "i" = paste(
        "Install {cli::qty(missing)}{?it/them} using",
        install_msg
      )
    )

    msg_fun(msg, call = rlang::caller_env())
  }

  invisible(any(is_available))
}
