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
