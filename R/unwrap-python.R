#' Unwrap Python
#'
#' Unwrap a wrapped Python object
#'
#' @param obj The object to unwrap
#'
#' @returns The Python object stored in `obj` or `obj` or it is not a
#'   `laminr.WrappedPythonObject` or `laminr.CallableWrappedPythonObject`
#' @noRd
unwrap_python <- function(obj) {

  # If obj is a list, unwrap every item
  if (is.list(obj) && is.vector(obj)) {
    return(purrr::map(obj, unwrap_python))
  }

  if (inherits(obj, "laminr.CallableWrappedPythonObject")) {
    obj <- attr(obj, "wrapped", exact = TRUE)
  }

  if (inherits(obj, "laminr.WrappedPythonObject")) {
    obj <- obj[[".__enclos_env__"]][["private"]][[".py_object"]]
  }

  if (is.function(obj)) {
    # Restore the stored function environment
    environment(obj) <- attr(obj, "original_env", exact = TRUE)
    attr(obj, "original_env") <- NULL
  }

  obj
}

#' Unwrap arguments and call
#'
#' Unwrap any arguments that contain Python objects and make a function call
#'
#' @param what The function to call
#' @param args A named list of function arguments
#' @param ... Additional arguments passed to [do.call()]
#'
#' @returns The results of `what` called with unwrapped `args`
#' @noRd
unwrap_args_and_call <- function(what, args, ...) {
  args <- purrr::map(args, unwrap_python)

  do.call(what, args, ...)
}
