#' @export
`$.laminr.CallableWrappedPythonObject` <- function(x, name) {
  wrapped <- attr(x, "wrapped", exact = TRUE)
  wrapped[[name]]
}

.DollarNames.laminr.CallableWrappedPythonObject <- function(x, pattern) {
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
