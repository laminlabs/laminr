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

      public[[.name]] <- make_py_function_wrapper(
        paste0("private$.py_object[['", .name, "']]"),
        value,
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

#' Get Python arguments
#'
#' Get a list of arguments for a Python function
#'
#' @param py_func The Python function to get arguments for
#'
#' @details
#' Arguments are found using the Python `inspect` function. If an arguments does
#' not have a default then the string "__NODEFAULT__" is returned for use by
#' other functions. This is to differentiate from arguments with a default value
#' of `NULL` or `NA`. Variable keyword arguments (e.g. `**kwargs`) and variable
#' positional arguments (e.g. `*args`) are given a default of `...`.
#'
#' @returns A named list where names are arguments and values and default values
#' @noRd
get_py_arguments <- function(py_func) {
  py_builtins <- reticulate::import_builtins()
  py_inspect <- reticulate::import("inspect")

  signature <- py_inspect$signature(py_func)
  params <- py_builtins$dict(signature$parameters)

  names(params)[names(params) == "function"] <- "func"

  lapply(params, function(.param) {
    default <- .param$default

    if (default == .param$empty) {
      default <- "__NODEFAULT__"
    }

    if (.param$kind == .param$VAR_KEYWORD) {
      default <- "..."
    }

    if (.param$kind == .param$VAR_POSITIONAL) {
      default <- "..."
    }

    # Replace complex defaults with ...
    if (inherits(default, "python.builtin.type")) {
      default <- "..."
    }

    default
  })
}

#' Make argument defaults string
#'
#' Make a string mapping arguments of a Python function to their default values,
#' e.g. `a, b, c = 1, d = "D", e = NA, f = NULL, ...`
#'
#' @param arguments A named list mapping arguments to their default values
#'
#' @returns A string describing arguments and default values
#' @noRd
make_argument_defaults_string <- function(arguments) {
  lapply(names(arguments), function(.argument) {
    default <- arguments[[.argument]]

    if (is.null(default)) {
      default <- "NULL"
    } else {
      # If the default is "..." replace it with literal `...` and no name
      if (default == "...") {
        return("...")
      }

      # The "__NODEFAULT__" string indicates a named arguments with no default
      if (default == "__NODEFAULT__") {
        return(.argument)
      }

      # Quote string default values
      if (is.character(default)) {
        default <- paste0("'", default, "'")
        check <- try(eval(parse(text = default)), silent = TRUE)
        if (inherits(check, "try-error")) {
          cli::cli_warn(
            "Failed to parse default string for argument {.arg { .argument}}, using {.val ''} instead"
          )
          default <- "''"
        }
      }

      # Python needs integer defaults to be kept as integers
      if (is.numeric(default) && (as.integer(default) == default)) {
        default <- paste0(as.integer(default), "L")
      }
    }

    paste(.argument, "=", default)
  }) |>
    unique() |>
    paste(collapse = ", ")
}

#' Make arguments usage string
#'
#' Make a string mapping arguments of a Python function to R variables,
#' e.g. `a = a, b = b, c = c, d = d, e = e, f = f, ...`
#'
#' @param arguments A named list mapping arguments to their default values
#'
#' @returns A string describing argument usage
#' @noRd
make_argument_usage_string <- function(arguments) {
  lapply(names(arguments), function(.argument) {
    default <- arguments[[.argument]]

    # If the default is "..." replace it with literal `...` and no name
    if (!is.null(default) && default == "...") {
      return("...")
    }

    paste(.argument, "=", .argument)
  }) |>
    unique() |>
    paste(collapse = ", ")
}

#' Make Python function wrapper
#'
#' Make a wrapper function for a function call that inherits arguments from a
#' Python function
#'
#' @param func_string A string giving the function to call inside the wrapper
#' @param py_func The Python function get inherit arguments from
#' @param self Whether to include `self` in the argument list. This is useful
#'  for wrapping class methods.
#' @param after_string If not `NULL`, the results of the function call will be
#'  piped into this
#'
#' @details
#' For a Python function with signature `def func(a, b=1, **kwargs)`, the result
#' is:
#'
#' ```r
#' function(a, b = 1, ...) {
#'   func(a, b = b, ...)
#' }
#' ```
#'
#' @returns A wrapper function around `func_string` that inherits arguments from
#'   `py_func`
#' @noRd
make_py_function_wrapper <- function(func_string, py_func, self = FALSE,
                                     after_string = NULL) {
  py_args <- get_py_arguments(py_func)
  defaults_string <- make_argument_defaults_string(py_args)
  usage_string <- make_argument_usage_string(py_args)

  self_string <- ifelse(self, "self, ", "")
  after_string <- ifelse(is.null(after_string), "", paste(" |>", after_string))

  fun_src <- paste0(
    "function(", defaults_string, ") {\n",
    "  ", func_string, "(", self_string, usage_string, ")", after_string, "\n",
    "}\n"
  )

  eval(parse(text = fun_src))
}
