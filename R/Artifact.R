#' @export
py_to_r.lamindb.models.Artifact <- function(obj) {
  wrap_python(
    obj,
    public = list(
      cache = artifact_cache,
      load = artifact_load
    )
  )
}

artifact_cache <- function(is_run_input = NULL) {
  private$.py_object$cache(is_run_input = is_run_input)$path
}

artifact_load <- function(is_run_input = NULL, ...) {
  file_path <- self$cache()
  suffix <- private$.py_object$suffix

  load_file(file_path, suffix, ...)
}
