#' Get R arguments
#'
#' Get a list of arguments for an R function
#'
#' @param func
#'
#' @details
#' Arguments are found using the R `formals` function. If an arguments does
#' not have a default then the string "__NODEFAULT__" is returned for use by
#' other functions. This is to differentiate from arguments with a default value
#' of `NULL` or `NA`.
#'
#' @returns A named list where names are arguments and values and default values
#' @noRd
get_r_arguments <- function(func) {
  purrr::map(as.list(formals(func)), function(.default) {
    default <- .default

    if (missing(default)) {
      default <- "__NODEFAULT__"
    }

    if (is.null(default)) {
      default <- "NULL"
    }

    default
  })
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
    }

    # The "__NODEFAULT__" string indicates a named arguments with no default
    if (default == "__NODEFAULT__") {
      return(.argument)
    }

    # If the default is "..." replace it with literal `...` and no name
    if (default == "...") {
      return("...")
    }

    # Quote string default values
    if (is.character(default) && default != "NULL") {
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
    if (.argument == "...") {
      default <- "..."
    } else {
      default <- arguments[[.argument]]
    }

    # If the default is "..." replace it with literal `...` and no name
    if (!is.null(default) && default == "...") {
      return("...")
    }

    paste(.argument, "=", .argument)
  }) |>
    unique() |>
    paste(collapse = ", ")
}
