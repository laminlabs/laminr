wrap_python <- function(py_object) {

  if (!inherits(py_object, "python.builtin.object")) {
    # Not a Python object so just return
    return(py_object)
  }

  # Ask reticulate to convert to R
  r_object <- reticulate::py_to_r(py_object)
  if (!inherits(r_object, "python.builtin.object")) {
    # Return the R object if converted
    return(r_object)
  }

  # class_split <- strsplit(class(py_object)[1], "\\.")[[1]]
  # class_name <- paste(class_split[1], rev(class_split)[1])

  class_name <- paste("wrapped", class(py_object)[1])

  public <- list(
    print = function() {
      print(private$.py_object)
    }
  )
  active <- list()
  for (.name in names(py_object)) {

    # Try to get the value for this slot
    value <- try(py_object[[.name]], silent = TRUE)
    if (inherits(value, "try-error")) {
      # Skip if there is an error
      # This should only happen if there is a Python error stopping this slot
      # from being accessed (e.g. ULabel.objects)
      next
    }

    if (inherits(value, c("python.builtin.function", "python.builtin.method"))) {
      arguments <- get_py_arguments(value)
      argument_defaults_string <- make_argument_defaults_string(arguments)
      argument_values_string <- make_argument_usage_string(arguments)

      fun_src <- paste0(
        "function(", argument_defaults_string, ") {\n",
        "  wrap_python(private$.py_object[['", .name, "']](", argument_values_string, "))",
        "\n}"
      )
      public[[.name]] <- eval(parse(text = fun_src))
    } else {
      fun_src <- paste0(
        "function() {\n",
        "  wrap_python(private$.py_object[['", .name, "']])",
        "\n}"
      )
      active[[.name]] <- eval(parse(text = fun_src))
    }
  }

  public <- add_class_methods(public, class(py_object))

  r6_class <- R6::R6Class(
    class_name,
    cloneable = FALSE,
    public = public,
    active = active,
    private = list(
      .py_object = py_object
    )
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

record_message <- function() {
  message("This is a record")
}

artifact_message <- function() {
  message("This is an artifact")
}

artifact_print <- function() {
  cat("--ARTIFACT--\n")
  print(private$.py_object)
}

class_methods <- list(
  lnschema_core.models.Artifact = list(
    message = artifact_message,
    print = artifact_print
  ),
  lnschema_core.models.Record = list(
    message = record_message
  )
)

add_class_methods <- function(methods, classes) {

  for (.class in rev(classes)) {
    if (.class %in% names(class_methods)) {
      method_functions <- class_methods[[.class]]
      for (.method in names(method_functions)) {
        methods[[.method]] <- method_functions[[.method]]
      }
    }
  }

  return(methods)
}

py_help <- function(py_obj) {

  py_builtins <- reticulate::import_builtins()

  py_builtins$help(py_obj)
}

# reticulate::register_module_help_handler
# reticulate::register_help_topics
