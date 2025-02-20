laminr_help_handler <- function(type, topic, source, ...) {
  # Convert the help source to an object with {reticulate}
  source <- source_as_object(source) # nolint object_usage_linter
  if (inherits(source, "laminr.CallableWrappedPythonObject")) {
    source <- attr(source, "wrapped", exact = TRUE)
  }
  # Extract the Python object
  # Don't use unwrap_python() here because of the namespace
  py_object <- source[[".__enclos_env__"]][["private"]][[".py_object"]]
  # Ask {reticulate} to handle help for the Python object
  help_handler(type, topic, py_object, ...) # nolint object_usage_linter
}
# This function uses internal {reticulate} functions so pretend it is part of
# "reticulate" namespace to avoid check warnings
environment(laminr_help_handler) <- asNamespace("reticulate")

lamindb_module_help_handler <- function(name, subtopic = NULL) {
  paste0("https://docs.lamin.ai/", tolower(name))
}
