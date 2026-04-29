# Base class for wrapped Python objects. Only exists to allow shared S3 methods.
# nolint next: object_name_linter.
WrappedPythonObject <- R6::R6Class(
  "laminr.WrappedPythonObject"
)

#' @export
.DollarNames.laminr.WrappedPythonObject <- function(x, pattern) {
  # Get the corresponding Python object
  py_object <- unwrap_python(x)
  # Get the dollar names for the Python object
  dollar_names <- utils::.DollarNames(py_object, pattern)
  # Replace the help handler
  attr(dollar_names, "helpHandler") <- "laminr:::laminr_help_handler"
  dollar_names
}

#' @export
r_to_py.laminr.WrappedPythonObject <- function(x, convert = FALSE) {
  py_object <- unwrap_python(x)
  assign("convert", convert, envir = py_object)
  py_object
}
