#' @export
as.list.lamindb.models.query_set.BasicQuerySet <- function(x, ...) { # nolint object_length_linter
  x$to_list()
}
