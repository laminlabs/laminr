#' Wrap a Python object
#'
#' Creates an [`R6::R6`] wrapper around a Python object where selected slots
#' are replaced
#'
#' @param obj The Python object to wrap
#' @param public A list of public members. Will replace any Python methods with
#'   the same names.
#' @param active A list of active binding functions. Will replace any Python
#'   items with the same names.
#' @param private A list of private members
#'
#' @details
#' The returned object will have the same class as the Python object, prefixed
#' with `laminr.`. Any class methods in the Python object should be accessible
#' with the same arguments and defaults as public members, unless they are
#' replaced by `public`. Any class variables in the Python object should be
#' available as active bindings, unless replaced by `active`. The original
#' Python object is store in `private$.py_object` and is accessed as needed.
#' Each object is wrapped independently so inheritance between classes is not
#' maintained.
#'
#' The suggested usage is to call `wrap_python` in a custom `py_to_r` method
#' for the class that needs to be wrapped.
#'
#' @returns An object from a custom R6 class wrapping the Python object
#' @noRd
wrap_python <- function(obj, public = list(), active = list(), private = list()) {
  class_name <- paste0("laminr.", class(obj)[1])

  # Make sure there is always a print method
  if (!"print" %in% names(public)) {
    public$print <- function() {
      print(private$.py_object)
    }
  }
  if (is.function(obj)) {
    # If obj is callable, store the environment so it can be restored later
    attr(obj, "original_env") <- environment(obj)
  }
  private$.py_object <- obj

  for (.name in names(obj)) {
    # Try to get the value for this slot
    value <- try(suppress_future_warning(obj[[.name]]), silent = TRUE)
    if (inherits(value, "try-error")) {
      # Skip if there is an error
      # This should only happen if there is a Python error stopping this slot
      # from being accessed
      next
    }

    # Class methods are stored as public members
    if (inherits(value, c("python.builtin.function", "python.builtin.method"))) {
      # Skip if this is already defined in public
      if (.name %in% names(public)) {
        next
      }

      public[[.name]] <- make_wrapper_function(
        paste0("private$.py_object[['", .name, "']]"),
        get_py_arguments(value),
        after_string = "py_to_r_nonull()"
      )
    } else {
      # Class variables are stored as active bindings

      # Skip if this is already defined in active
      if (.name %in% names(active)) {
        next
      }

      # Build a function that accesses the correct variable in the Python object
      fun_src <- paste0(
        "function(value) {\n",
        "  get_or_set_python_slot(private$.py_object, '", .name, "', value)",
        "\n}"
      )

      active[[.name]] <- eval(parse(text = fun_src))
    }
  }

  r6_class <- R6::R6Class(
    class_name,
    inherit = WrappedPythonObject,
    cloneable = FALSE,
    public = public,
    active = active,
    private = private
  )

  r6_class$new()
}

#' Wrap a callable Python object
#'
#' Creates a wrapper around a Python object where selected slots
#' are replaced and it can be called as a function
#'
#' @param obj The Python object to wrap
#' @param call A function used when the object is called. If `NULL` a generic
#'   function will be used.
#' @param public A list of public members. Will replace any Python methods with
#'   the same names.
#' @param active A list of active binding functions. Will replace any Python
#'   items with the same names.
#' @param private A list of private members
#'
#' @details
#' The Python object is wrapped using `wrap_python()`. The result is included as
#' attribute of a structure where `call` is the main data. S3 methods allow the
#' slots of the wrapped object to be called while also allowing the whole object
#' to be called.
#'
#' @references https://github.com/r-lib/R6/issues/220
#'
#' @returns A callable structure wrapping the Python object
#' @noRd
wrap_python_callable <- function(obj, call = NULL, public = list(), active = list(), private = list()) {
  if (is.null(call)) {
    # Avoid "no visible binding" NOTE
    self <- NULL

    call <- function(...) {
      py_object <- unwrap_python(self)
      unwrap_args_and_call(py_object, list(...))
    }
  }
  public$call <- call

  wrapped <- wrap_python(obj, public = public, active = active, private = private)

  structure(
    wrapped$call,
    wrapped = wrapped,
    class = c(class(wrapped)[1], "laminr.CallableWrappedPythonObject")
  )
}

#' Get or set Python slot
#'
#' Get or set the value for a slot of a Python object
#'
#' @param py_object The Python object to get or set
#' @param slot The slot to get or set
#' @param value The value to set `slot` to
#'
#' @returns If `value` is missing, the current value of `slot`, otherwise, the
#'   results of setting `slot`
#' @noRd
get_or_set_python_slot <- function(py_object, slot, value) {
  if (missing(value)) {
    return(py_to_r(py_object[[slot]]))
  }

  tryCatch(
    py_object[[slot]] <- r_to_py(value),
    error = function(err) {
      cli::cli_abort(c(
        "Failed to set slot {.field {slot}} of {.cls {class(py_object)[1]}} object",
        "x" = "Error message: {err}",
        "i" = "Run {.run reticulate::py_last_error()} for details"
      ))
    }
  )
}

#' Make a wrapper function
#'
#' Make a wrapper function for a function call with given arguments
#'
#' @param func_string A string giving the function to call inside the wrapper
#' @param args A named list mapping arguments to their default values
#' @param ignore_defaults A vector of argument names to ignore when creating the
#'  wrapper function signature
#' @param after_string If not `NULL`, the results of the function call will be
#'  piped into this
#'
#' @details
#' For function string `"func"` with
#' `args = list(a = "_NODEFAULT_, b = 1, **kwargs = "...")`, the result is:
#'
#' ```r
#' function(a, b = 1, ...) {
#'   func(a = a, b = b, ...)
#' }
#' ```
#'
#' @returns A wrapper function around `func_string` that inherits `args`
#' @noRd
make_wrapper_function <- function(func_string, args, ignore_defaults = NULL,
                                  after_string = NULL) {
  defaults_string <- make_argument_defaults_string(args[!(names(args) %in% ignore_defaults)])
  usage_string <- make_argument_usage_string(args)

  after_string <- ifelse(is.null(after_string), "", paste(" |>", after_string))

  fun_src <- paste0(
    "function(", defaults_string, ") {\n",
    "  ", func_string, "(", usage_string, ")", after_string, "\n",
    "}\n"
  )

  eval(parse(text = fun_src))
}

#' Wrap with Python arguments
#'
#' Make a wrapper around an R function that inserts Python arguments into `...`
#'
#' @param func The R function to wrap
#' @param py_func The Python function to insert arguments from
#' @param ignore_defaults A vector of argument names to ignore when creating the
#'   wrapper function signature. By default, `self` and `private` are ignored
#'   from the wrapper function but still included in the function call for use
#'   in creating `R6` methods.
#'
#' @details
#' Arguments from `py_func` are inserted into the `...` argument of `func` so
#' `func` must have a `...` argument.
#'
#' For an R function with signature `r_fun <- function(c, d = 2, ..., e = NULL)`
#' and a Python function with signature `def func(a, b=1, **kwargs)`, the result
#' is:
#'
#' ```r
#' function(c, d = 2, a, b = 1, ..., e = NULL) {
#'   r_fun(c = c, d = d, a = a, b = b, ..., e = e)
#' }
#' ```
#'
#' @returns A wrapper function around `func` that inserts arguments from
#'   `py_func`
#' @noRd
wrap_with_py_arguments <- function(func, py_func, ignore_defaults = c("self", "private")) {
  func_name <- deparse(substitute(func))
  func_args <- get_r_arguments(func)

  if (!("..." %in% names(func_args))) {
    cli::cli_abort(
      "The {.fun {func_name}} function is missing a '...' argument to insert arguments into"
    )
  }

  py_args <- get_py_arguments(py_func)

  args_split <- split_at(func_args, which(names(func_args) == "..."))

  args <- c(args_split$head, py_args, args_split$tail)

  make_wrapper_function(func_name, args, ignore_defaults = ignore_defaults)
}
