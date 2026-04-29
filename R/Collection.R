#' @export
# nolint next: object_length_linter.
py_to_r.lamindb.models.collection.Collection <- function(x) {
  wrap_python(
    x,
    public = list(
      view_lineage = wrap_with_py_arguments(view_lineage_graph, x$view_lineage)
    )
  )
}
