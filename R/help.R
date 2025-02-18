help_handler <- function(type, topic, source, ...) {
  # Convert the help source to an object
  source <- reticulate:::source_as_object(source)
  # Extract the Python object
  py_object <- source[[".__enclos_env__"]][["private"]][[".py_object"]]
  # Ask {reticulate} to handle help for the Python object
  reticulate:::help_handler(type, topic, py_object, ...)
}
