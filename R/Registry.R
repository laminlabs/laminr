#' @export
py_to_r.lamindb.models.record.Registry <- function(x) {
  wrap_registry(x)
}

#' @export
# nolint start: object_length_linter
py_to_r.lamindb.models.sqlrecord.Registry <- function(x) {
  # nolint end: object_length_linter
  wrap_registry(x)
}

wrap_registry <- function(py_registry) {
    wrap_python_callable(
      py_registry,
      public = list(
        from_df = if ("from_df" %in% names(py_registry)) {
          wrap_with_py_arguments(registry_from_df, py_registry$from_df)
        },
        from_dataframe = if ("from_dataframe" %in% names(py_registry)) {
          wrap_with_py_arguments(registry_from_df, py_registry$from_dataframe)
        }
      ) |>
        purrr::compact()
    )
}

registry_from_df <- function(self, ...) {
  args <- list(...)

  if (!is.data.frame(args$df)) {
    df_class <- class(args$df)[1] # nolint object_usage_linter
    cli::cli_abort(
      "{.arg df} must be a {.cls data.frame} but is a {.cls {df_class}}"
    )
  }

  if (
    !is.null(args$revises) &&
      !inherits(args$revises, "laminr.lamindb.models.artifact.Artifact")
  ) {
    revises_class <- class(args$revises)[1] # nolint object_usage_linter
    cli::cli_abort(
      "{.arg revises} must be an {.cls Artifact} but is a {.cls {revises_class}}"
    )
  }

  args$df <- standardise_list_columns(args$df)

  py_object <- unwrap_python(self)
  unwrap_args_and_call(py_object$from_df, args)
}
