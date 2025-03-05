#' @export
py_to_r.lamindb.models.collection.Collection <- function(x) { # nolint object_length_linter
  wrap_python(
    x,
    public = list(
      view_lineage = function(with_children = TRUE) {
        view_lineage()
      }
    )
  )
}
