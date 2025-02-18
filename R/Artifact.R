#' @export
py_to_r.lamindb.models.Artifact <- function(x) {
  # Avoid "no visible binding for global variable"
  self <- NULL
  private <- NULL

  wrap_python(
    x,
    public = list(
      cache = function(is_run_input = NULL) {
        artifact_cache(private, is_run_input)
      },
      load = function(is_run_input = NULL, ...) {
        artifact_load(self, private, is_run_input, ...)
      },
      open = function(mode = "r", is_run_input = NULL, ...) {
        artifact_open(self, private, mode, is_run_input, ...)
      }
    )
  )
}

artifact_cache <- function(private, is_run_input) {
  private$.py_object$cache(is_run_input = is_run_input)$path
}

artifact_load <- function(self, private, is_run_input, ...) {
  file_path <- self$cache()
  suffix <- private$.py_object$suffix

  load_file(file_path, suffix, ...)
}

artifact_open <- function(self, private, mode, is_run_input, ...) {
  artifact_uri <- paste0(self$storage$root, "/", self$key)
  otype <- self$otype

  conn <- open_file(artifact_uri, otype, ...)

  # Tell Python to track this artifact
  ln <- reticulate::import("lamindb")
  ln$core$`_data`$`_track_run_input`(private$.py_object, is_run_input)

  conn
}
