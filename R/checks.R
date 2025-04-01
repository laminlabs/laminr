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
  language <- match.arg(language)

  is_available <- if (language == "R") {
    purrr::map_lgl(requires, requireNamespace, quietly = TRUE)
  } else {
    purrr::map_lgl(requires, reticulate::py_module_available)
  }

  msg_fun <- get_message_fun(alert)

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

#' Check default instance
#'
#' Check if a default LaminDB instance has already been set
#'
#' @param instance A LaminDB instance slug. If this matches the current instance
#'   no alert will be issued.
#' @param alert The type of alert message to give
#'
#' @returns Whether to not there is a current default instance, invisibly
#' @noRd
check_default_instance <- function(instance = NULL, alert = c("error", "warning", "message", "none")) {
  alert <- match.arg(alert)
  current_default <- get_default_instance()
  check <- !is.null(current_default)

  if (check && !is.null(instance)) {
    return(invisible(TRUE))
  }

  msg_fun <- get_message_fun(alert)
  if (check && !is.null(msg_fun)) {
    advice <- switch(alert,
      error = c(
        "x" = "This command will not be run",
        "i" = "Start a new R session before attempting to run it"
      ),
      warning = c(
        "i" = "It is recommended to start a new R session"
      )
    )

    msg_fun(c(
      "There is already a default instance connected ({.val {current_default}})",
      advice
    ), call = rlang::caller_env())
  }

  invisible(check)
}

#' Check instance module
#'
#' Check if a Python module is in the included modules for the current LaminDB
#' instance
#'
#' @param module The name of the Python module to check for
#' @param alert The type of alert message to give
#'
#' @returns Whether `module` is included in the current instance, invisibly
#' @noRd
check_instance_module <- function(module, alert = c("error", "warning", "message", "none")) {
  current_default <- get_default_instance()
  msg_fun <- get_message_fun(alert)

  # If there is no current instance just return
  if (is.null(current_default)) {
    return()
  }

  ln_setup <- reticulate::import("lamindb_setup")

  check <- try(
    ln_setup$`_check_setup`$`_check_module_in_instance_modules`(module),
    silent = TRUE
  )
  check <- !inherits(check, "try-error")

  if (isFALSE(check) && !is.null(msg_fun)) {
    msg_fun(
      "The current instance ({.val {current_default}}) does not include the {.pkg {module}} module",
      call = rlang::caller_env()
    )
  }

  invisible(check)
}
