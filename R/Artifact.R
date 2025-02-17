#' @export
py_to_r.lamindb.models.Artifact <- function(obj) {
  wrap_python(
    obj,
    public = list(
      cache = artifact_cache,
      load = artifact_load,
      open = artifact_open
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

artifact_open <- function(mode = 'r', is_run_input = NULL, ...) {
  artifact_uri <- paste0(self$storage$root, "/", self$key)
  otype <- self$otype

  conn <- open_file(artifact_uri, otype, ...)

  # Tell Python to track this artifact
  ln <- reticulate::import("lamindb")
  ln$core$`_data`$`_track_run_input`(private$.py_object, is_run_input)

  return(conn)
}
