#' @export
# nolint next: object_length_linter.
as.list.lamindb.models.query_set.BasicQuerySet <- function(x, ...) {
  x$to_list()
}
