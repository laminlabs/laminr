#' @export
py_to_r.lamindb.models.Transform <- function(x) {
  # Avoid "no visible binding for global variable"
  self <- NULL

  wrap_python(
    x,
    public = list(
      view_lineage = function(with_children = TRUE) {
        view_lineage()
      }
    )
  )
}
