py_to_r_ifneedbe <- function(obj) {
  # Not a Python object so just return
  if (!inherits(obj, "python.builtin.object")) {
    return(obj)
  }

  # Ask reticulate to convert to R
  reticulate::py_to_r(obj)
}

py_to_r.lnschema_core.models.Record <- function(obj) {
  wrap_python(
    obj,
    public = list(
      message = function() {
        message("This is a record")
      }
    )
  )
}

py_to_r.lnschema_core.models.Artifact <- function(obj) {
  wrap_python(
    obj,
    public = list(
      message = function() {
        message("This is an artifact")
      },
      print = function() {
        cat("--ARTIFACT--\n")
        print(private$.py_object)
      }
    )
  )
}


wrap_python <- function(obj, public = list(), active = list(), private = list()) {
  class_name <- paste0("laminr.", class(obj)[1])

  if (!"print" %in% names(public)) {
    public$print <- function() {
      print(private$.py_object)
    }
  }
  private$.py_object <- obj

  for (.name in names(obj)) {

    # Try to get the value for this slot
    value <- try(obj[[.name]], silent = TRUE)
    if (inherits(value, "try-error")) {
      # Skip if there is an error
      # This should only happen if there is a Python error stopping this slot
      # from being accessed (e.g. ULabel.objects)
      next
    }

    if (inherits(value, c("python.builtin.function", "python.builtin.method"))) {
      # skip if this is already defined
      if (.name %in% names(public)) {
        next
      }

      arguments <- get_py_arguments(value)
      argument_defaults_string <- make_argument_defaults_string(arguments)
      argument_values_string <- make_argument_usage_string(arguments)

      fun_src <- paste0(
        "function(", argument_defaults_string, ") {\n",
        "  py_to_r_ifneedbe(private$.py_object[['", .name, "']](", argument_values_string, "))",
        "\n}"
      )
      public[[.name]] <- eval(parse(text = fun_src))
    } else {
      # skip if this is already defined
      if (.name %in% names(active)) {
        next
      }

      fun_src <- paste0(
        "function() {\n",
        "  py_to_r_ifneedbe(private$.py_object[['", .name, "']])",
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

make_argument_defaults_string <- function(arguments) {
  lapply(names(arguments), function(.argument) {

    default <- arguments[[.argument]]

    if (is.null(default)) {
      default <- "NULL"
    } else {
      if (default == "...") {
        return("...")
      }

      if (default == "__NODEFAULT__") {
        return(.argument)
      }

      if (is.character(default)) {
        default <- paste0("'", default, "'")
      }

      if (is.numeric(default) && (as.integer(default) == default)) {
        default <- paste0(as.integer(default), "L")
      }
    }

    paste(.argument, "=", default)
  }) |>
    paste(collapse = ", ")
}

make_argument_usage_string <- function(arguments) {
  lapply(names(arguments), function(.argument) {
    default <- arguments[[.argument]]

    if (!is.null(default) && default == "...") {
      return("...")
    }

    paste(.argument, "=", .argument)
  }) |>
    paste(collapse = ", ")
}

py_help <- function(py_obj) {

  py_builtins <- reticulate::import_builtins()

  py_builtins$help(py_obj)
}

# reticulate::register_module_help_handler
# reticulate::register_help_topics
