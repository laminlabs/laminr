#' @export
py_to_r.lamindb.models.Registry <- function(x) {
  # Avoid "no visible binding for global variable"
  self <- NULL

  wrap_python_callable(
    x,
    call = function(...) {
      registry_call(self, ...)
    },
    public = list(
      from_df = function(df, key = NULL, description = NULL, run = NULL, revises = NULL, ...) {
        registry_from_df(self, df = df, key = key, description = description, run = run, revises = revises, ...)
      }
    )
  )
}

registry_call <- function(wrapped, ...) {
  py_object <- unwrap_python(wrapped)
  unwrap_args_and_call(py_object, list(...))
}

registry_from_df <- function(self, ...) {
  args <- list(...)

  if (!is.data.frame(args$df)) {
    df_class <- class(args$df)[1]
    cli::cli_abort(
      "{.arg df} must be a {.cls data.frame} but is a {.cls {df_class}}"
    )
  }

  if (!is.null(args$revises) && !inherits(args$revises, "laminr.lamindb.models.Artifact")) {
    revises_class <- class(args$revises)[1]
    cli::cli_abort(
      "{.arg revises} must be an {.cls Artifact} but is a {.cls {revises_class}}"
    )
  }

  py_object <- unwrap_python(self)
  unwrap_args_and_call(py_object$from_df, args)
}
