#' Check required packages
#'
#' Check that required packages are available and give a nice message with
#' install instructions if not
#'
#' @param what A message stating what the packages are required for. Used at the
#'   start of the error message e.g. "{what} requires...".
#' @param requires Character vector of required package names
#' @param language The language to check if the package exists, either "R" or
#'   "Python"
#' @param extra_repos Additional repositories that are required to install the
#'   checked packages (only for R)
#' @param ... Arguments passed to `issue_check_alert()`
#'
#' @return Whether or not all packages are available, invisibly
#' @noRd
check_requires <- function(what, requires, language = c("R", "Python"),
                           extra_repos = NULL, ...) {
  language <- match.arg(language)

  is_available <- if (language == "R") {
    purrr::map_lgl(requires, requireNamespace, quietly = TRUE)
  } else {
    purrr::map_lgl(requires, reticulate::py_module_available)
  }
  all_available <- all(is_available)

  if (all_available) {
    return(invisible(TRUE))
  }

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
    paste0(
      "{.run ",
      paste(
        paste0("require_module('", missing, "')"),
        collapse = "; "
      ),
      "}"
    )
  }

  msg <- c(
    msg,
    "i" = paste(
      "Install {cli::qty(missing)}{?it/them} using",
      install_msg
    )
  )

  issue_check_alert(
    !all_available,
    msg = msg,
    ...
  )

  invisible(all_available)
}

#' Check default instance
#'
#' Check if a default LaminDB instance has already been set
#'
#' @param instance A LaminDB instance slug. If this matches the current instance
#'   no alert will be issued.
#' @param alert The type of alert message to give
#' @param ... Arguments passed to `issue_check_alert()`
#'
#' @returns Whether to not there is a current default instance, invisibly
#' @noRd
check_default_instance <- function(instance = NULL, alert = c("error", "warning", "message", "none"), ...) {
  alert <- match.arg(alert)
  current_default <- get_default_instance()
  is_default_instance <- !is.null(current_default)

  if (is_default_instance && identical(instance, current_default)) {
    return(invisible(TRUE))
  }

  advice <- switch(alert,
     error = c(
       "x" = "This command will not be run",
       "i" = "Start a new R session before attempting to run it"
     ),
     warning = c(
       "i" = "It is recommended to start a new R session"
     )
  )

  msg <- c(
    "There is already a default instance connected ({.val {current_default}})",
    advice
  )

  issue_check_alert(
    is_default_instance,
    msg = msg,
    alert = alert,
    ...
  )

  invisible(is_default_instance)
}

#' Check instance module
#'
#' Check if a Python module is in the included modules for the current LaminDB
#' instance
#'
#' @param module The name of the Python module to check for
#' @param ... Arguments passed to `issue_check_alert()`
#'
#' @returns Whether `module` is included in the current instance, invisibly
#' @noRd
check_instance_module <- function(module, ...) {
  current_instance <- get_current_lamin_instance(ignore_none = FALSE, silent = TRUE)
  if (is.null(current_instance)) {
    return()
  }

  settings <- get_current_lamin_settings(silent = TRUE)
  instance_modules <- settings$instance$modules
  is_module_available <- module %in% instance_modules

  issue_check_alert(
    isFALSE(is_module_available),
    msg = "The current instance ({.val {current_instance}}) does not include the {.pkg {module}} module",
    ...
  )

  invisible(is_module_available)
}

#' Check in RStudio
#'
#' Check if R is currently running in RStudio
#'
#' @param ... Arguments passed to `issue_check_alert()`
#'
#' @returns Whether or not R is running in RStudio, invisibly
#' @noRd
check_in_rstudio <- function(...) {
  in_rstudio <- check_requires("Running in RStudio", "rstudioapi", alert = "none") &&
    rstudioapi::isAvailable()

  issue_check_alert(
    in_rstudio,
    msg = "{.pkg laminr} appears to be running in RStudio",
    ...
  )

  invisible(in_rstudio)
}

#' Check in knitr notebook
#'
#' Check if R is currently running in a knitr notebook
#'
#' @param ... Arguments passed to `issue_check_alert()`
#'
#' @returns Whether or not R is running in a knitr notebook, invisibly
#' @noRd
check_in_knitr_notebook <- function(...) {
  in_knitr_notebook <- check_requires("Running in a knitr notebook", "knitr", alert = "none") &&
    !is.null(knitr::opts_knit$get("out.format"))

  issue_check_alert(
    in_knitr_notebook,
    msg = "{.pkg laminr} appears to be running in a knitr notebook",
    ...
  )

  invisible(in_knitr_notebook)
}

#' Check on Jupyter
#'
#' Check if R is currently running on Jupyter
#'
#' @param ... Arguments passed to `issue_check_alert()`
#'
#' @returns Whether or not R is running on Jupyter, invisibly
#' @noRd
check_on_jupyter <- function(...) {
  is_on_jupyter <- check_requires("Running on Jupyter", "IRkernel", alert = "none") &&
    !is.null(IRkernel::comm_manager())

  issue_check_alert(
    is_on_jupyter,
    msg = "{.pkg laminr} appears to be running in a Jupyter environment",
    ...
  )

  invisible(is_on_jupyter)
}

#' Issue check alert
#'
#' Issue an alert message for a check
#'
#' @param issue_alert Whether or not to issue an alert. Should depend on the
#'   relevant check and if an alert should be issued if it is `TRUE` or `FALSE`.
#' @param msg The message to send if an alert is issued
#' @param alert The type of alert message to give, see `get_message_fun()`
#' @param info A vector of additional information appended to the message
#'   formatted with [cli::cli_bullets()]
#' @param call The calling environment to use in the alert, see
#'   `cli::cli_abort()`
#'
#'
#' @returns Whether or not an alert message was issued, invisibly
#' @noRd
issue_check_alert <- function(issue_alert, msg,
                              alert = c("error", "warning", "message", "none"),
                              info = NULL, call = rlang::caller_env(2)) {
  alert <- match.arg(alert)
  msg_fun <- get_message_fun(alert)
  issue_alert <- issue_alert && !is.null(msg_fun)

  if (issue_alert) {
    if (!is.null(info)) {
      msg <- c(msg, info)
    }

    msg_fun(msg, call = call)
  }

  invisible(issue_alert)
}
