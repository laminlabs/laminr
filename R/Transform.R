#' @export
py_to_r.lamindb.models.transform.Transform <- function(x) { # nolint object_length_linter
  wrap_python(
    x,
    public = list(
      view_lineage = wrap_with_py_arguments(view_lineage_graph, x$view_lineage)
    )
  )
}
