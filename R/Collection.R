#' @export
py_to_r.lamindb.models.collection.Collection <- function(x) { # nolint object_length_linter
  wrap_python(
    x,
    public = list(
      view_lineage = wrap_with_py_arguments(view_lineage, x$view_lineage)
    )
  )
}
