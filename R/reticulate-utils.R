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

#' Convert a Lamin settings object to a list
#'
#' @param py_obj The Python Lamin settings object to convert
#'
#' @returns
#' @export
#'
#' @examples
py_settings_to_list <- function(py_obj) {
  # If not a Python object, just return
  if (!is(py_obj, "python.builtin.object")) {
    return(py_obj)
  }

  # Return NULL for Python methods
  if (inherits(py_obj, "python.builtin.method")) {
    return(NULL)
  }

  # Convert Python sets to lists
  if (inherits(py_obj, "python.builtin.set")) {
    py_builtins <- reticulate::import_builtins()
    return(reticulate::py_to_r(py_builtins$list(py_obj)))
  }

  # If not a settings object, just return the class
  py_class <- class(py_obj)
  if (!grepl("^lamindb.*Settings$", py_class[1])) {
    return(py_class)
  }

  # Recursively convert items in the settings object
  purrr::map(names(py_obj), function(.name) {
    # Try to extract the item, if it fails return the error message
    value <- tryCatch(
      suppress_future_warning(reticulate::py_to_r(py_obj[[.name]])),
      error = function(err) {
        paste("ERROR:", as.character(err))
      }
    )

    py_settings_to_list(value)
  }) |>
    purrr::set_names(names(py_obj)) |>
    # Remove NULL values to avoid empty entries for methods
    purrr::compact()
}
