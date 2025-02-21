#' Python to R (no NULL)
#'
#' Convert a Python object to R, except if it is `NULL`
#'
#' @param x The Python object to convert
#'
#' @returns The result of `reticulate::py_to_r(x)` unless it is `NULL` in which
#'   case `invisible(NULL)`
#' @noRd
py_to_r_nonull <- function(x) {
  x <- reticulate::py_to_r(x)

  if (is.null(x)) {
    invisible(NULL)
  } else {
    x
  }
}

#' Suppress FutureWarning
#'
#' Suppress Python FutureWarning warnings for when they are expected but
#' shouldn't be visible to users
#'
#' @param expr The expression to run
#'
#' @returns The results of `eval(expr)`
#' @noRd
suppress_future_warning <- function(expr) {
  py_builtins <- reticulate::import_builtins() # nolint object_usage_linter
  warnings <- reticulate::import("warnings")

  with(warnings$catch_warnings(), {
    warnings$simplefilter(action = "ignore", category = py_builtins$FutureWarning)
    eval(expr)
  })
}
