#' @export
`$.laminr.CallableWrappedPythonObject` <- function(x, name) { # nolint object_length_linter
  wrapped <- attr(x, "wrapped", exact = TRUE)
  wrapped[[name]]
}

#' @export
.DollarNames.laminr.CallableWrappedPythonObject <- function(x, pattern) { # nolint object_length_linter object_name_linter
  # Get the wrapped Python object
  wrapped <- attr(x, "wrapped", exact = TRUE)
  # Get the corresponding Python object
  py_object <- unwrap_python(wrapped)
  # Get the dollar names for the Python object
  dollar_names <- utils::.DollarNames(py_object, pattern)
  # Replace the help handler
  attr(dollar_names, "helpHandler") <- "laminr:::laminr_help_handler"
  dollar_names
}

#' @export
print.laminr.CallableWrappedPythonObject <- function(x, ...) { # nolint object_length_linter
  print(attr(x, "wrapped", exact = TRUE))
}

#' @export
r_to_py.laminr.CallableWrappedPythonObject <- function(x, convert = FALSE) {
  py_object <- unwrap_python(x)
  assign("convert", convert, envir = py_object)
  py_object
}
