#' @export
py_to_r.lamindb.models.Artifact <- function(x) {
  # Avoid "no visible binding for global variable"
  self <- NULL
  private <- NULL

  wrap_python(
    x,
    public = list(
      cache = function(is_run_input = NULL) {
        artifact_cache(self, is_run_input = is_run_input)
      },
      load = function(is_run_input = NULL, ...) {
        artifact_load(self, is_run_input = is_run_input, ...)
      },
      open = function(mode = "r", is_run_input = NULL, ...) {
        artifact_open(self, mode = mode, is_run_input = is_run_input, ...)
      }
    )
  )
}

artifact_cache <- function(self, ...) {
  py_object <- unwrap_python(self)

  cache_path <- unwrap_args_and_call(py_object$cache, list(...))
  cache_path$path
}

artifact_load <- function(self, is_run_input, ...) {
  file_path <- self$cache(is_run_input = is_run_input)
  suffix <- self$suffix

  load_file(file_path, suffix, ...)
}

artifact_open <- function(self, mode, is_run_input, ...) {
  artifact_uri <- paste0(self$storage$root, "/", self$key)
  otype <- self$otype

  conn <- open_file(artifact_uri, otype, ...)

  # Tell Python to track this artifact
  ln <- reticulate::import("lamindb")
  py_object <- unwrap_python(self)
  ln$core$`_data`$`_track_run_input`(py_object, is_run_input)

  conn
}
