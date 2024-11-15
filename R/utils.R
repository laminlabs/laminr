#' Check required packages
#'
#' Check that required packages are available and give a nice error message with
#' install instructions if not
#'
#' @param what A message stating what the packages are required for. Used at the
#'   start of the error message e.g. "{what} requires...".
#' @param requires Character vector of required package names
#'
#' @return `TRUE` invisibly if all packages are available, otherwise calls
#'   [cli::cli_abort()]
#' @noRd
check_requires <- function(what, requires) {
  is_available <- map_lgl(requires, requireNamespace, quietly = TRUE)

  if (any(!is_available)) {
    missing <- requires[!is_available]
    missing_str <- paste0("'", paste(missing, collapse = "', '"), "'") # nolint object_usage_linter
    cli_abort(
      c(
        "{what} requires the {.pkg {missing}} package{?s}",
        "i" = paste(
          "To continue, install {cli::qty(missing)}{?it/them} using",
          "{.code install.packages(c({missing_str}))}"
        )
      ),
      call = rlang::caller_env()
    )
  }

  invisible(TRUE)
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
