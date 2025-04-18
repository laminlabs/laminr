# Base class for wrapped Python objects. Only exists to allow shared S3 methods.
WrappedPythonObject <- R6::R6Class( # nolint object_name_linter
  "laminr.WrappedPythonObject"
)

#' @export
.DollarNames.laminr.WrappedPythonObject <- function(x, pattern) { # nolint object_length_linter object_name_linter
  # Get the corresponding Python object
  py_object <- unwrap_python(x)
  # Get the dollar names for the Python object
  dollar_names <- utils::.DollarNames(py_object, pattern)
  # Replace the help handler
  attr(dollar_names, "helpHandler") <- "laminr:::laminr_help_handler"
  dollar_names
}

#' @export
r_to_py.laminr.WrappedPythonObject <- function(x, convert = FALSE) { # nolint object_length_linter object_name_linter
  py_object <- unwrap_python(x)
  assign("convert", convert, envir = py_object)
  py_object
}
