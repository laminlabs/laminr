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

      arguments <- get_py_arguments(value)
      argument_defaults_string <- make_argument_defaults_string(arguments)
      argument_values_string <- make_argument_usage_string(arguments)

      # Build a function that has the correct arguments, defaults and usage
      # and passes those to the Python method
      fun_src <- paste0(
        "function(", argument_defaults_string, ") {\n",
        "  py_to_r_nonull(\n",
        "    private$.py_object[['", .name, "']](", argument_values_string, ")\n",
        "  )\n",
        "\n}"
      )

      public[[.name]] <- eval(parse(text = fun_src))
    } else {
      # Class variables are stored as active bindings

      # Skip if this is already defined in active
      if (.name %in% names(active)) {
        next
      }

      # Build a function that accesses the correct variable in the Python object
      fun_src <- paste0(
        "function() {\n",
        "  py_to_r(private$.py_object[['", .name, "']])",
        "\n}"
      )

      active[[.name]] <- eval(parse(text = fun_src))
    }
  }

  r6_class <- R6::R6Class(
    class_name,
    cloneable = FALSE,
    public = public,
    active = active,
    private = private
  )

  r6_class$new()
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
#' of `NULL` or `NA`. Variable keyword arguments (e.g. `**kwargs`) are given a
#' default of `...`.
#'
#' @returns A named list where names are arguments and values and default values
#' @noRd
get_py_arguments <- function(py_func) {

  py_builtins <- reticulate::import_builtins()
  py_inspect <- reticulate::import("inspect")

  signature <- py_inspect$signature(py_func)
  params <- py_builtins$dict(signature$parameters)

  lapply(params, function(.param) {
    default <- .param$default

    if (default == .param$empty) {
      default = "__NODEFAULT__"
    }

    if (.param$kind == .param$VAR_KEYWORD) {
      default = "..."
    }

    return(default)
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
      }

      # Python needs integer defaults to be kept as integers
      if (is.numeric(default) && (as.integer(default) == default)) {
        default <- paste0(as.integer(default), "L")
      }
    }

    paste(.argument, "=", default)
  }) |>
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
    paste(collapse = ", ")
}

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
    return(x)
  }
}

#' Suppress FutureWarning
#'
#' Suppress Python FutureWarning warnings for when they are expected but
#' shouldn't be visible to users
#'
#' @param expr The expression to run
#'
#' @returns The results of `expr`
#' @noRd
suppress_future_warning <- function(expr) {
  py_builtins <- reticulate::import_builtins()
  warnings <- reticulate::import("warnings")

  with(warnings$catch_warnings(), {
    warnings$simplefilter(action='ignore', category=py_builtins$FutureWarning)
    eval(expr)
  })
}
