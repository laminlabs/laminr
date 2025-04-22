#' @export
py_to_r.lamindb.models.transform.Transform <- function(x) { # nolint object_length_linter
  wrap_python(
    x,
    public = list(
      view_lineage = make_py_function_wrapper("view_lineage", x$view_lineage, self = FALSE)
    )
  )
}
