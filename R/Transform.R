#' @export
py_to_r.lamindb.models.Transform <- function(x) {
  wrap_python(
    x,
    public = list(
      view_lineage = function(with_children = TRUE) {
        view_lineage()
      }
    )
  )
}
