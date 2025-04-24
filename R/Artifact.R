#' @export
py_to_r.lamindb.models.artifact.Artifact <- function(x) { # nolint object_length_linter
  # Avoid "no visible binding for global variable"
  self <- NULL

  wrap_python(
    x,
    public = list(
      cache = wrap_with_py_arguments(artifact_cache, x$cache),
      load = wrap_with_py_arguments(artifact_load, x$load),
      open = function(mode = "r", is_run_input = NULL, ...) {
        artifact_open(self, mode = mode, is_run_input = is_run_input, ...)
      },
      view_lineage = wrap_with_py_arguments(view_lineage_graph, x$view_lineage)
    )
  )
}

artifact_cache <- function(self, ...) {
  py_object <- unwrap_python(self)

  cache_path <- unwrap_args_and_call(py_object$cache, list(...))
  cache_path$path
}

artifact_load <- function(self, ..., .reader_args = NULL) {
  if (is.null(.reader_args)) {
    .reader_args <- list(
      file = self$cache(...),
      suffix = self$suffix
    )
  } else {
    .reader_args[["file"]] <- self$cache(...)
    .reader_args[["suffix"]] <- self$suffix
  }

  do.call(load_file, .reader_args)
}

artifact_open <- function(self, mode, is_run_input, ...) {
  py_lamin <- reticulate::import("lamindb")
  py_object <- unwrap_python(self)

  filepath_cache_key <- py_lamin$core$storage$paths$filepath_cache_key_from_artifact(py_object)
  local_path <- py_lamin$setup$settings$paths$cloud_to_local_no_update(
    filepath_cache_key[[1]],
    cache_key = filepath_cache_key[[2]]
  )

  otype <- self$otype

  if (local_path$exists()) {
    conn <- open_file(local_path$path, otype, ...)
  } else {
    remote_path <- tryCatch(
      filepath_cache_key[[1]]$as_posix(),
      error = function(err) {
        filepath_cache_key[[1]]$path
      }
    )
    conn <- open_file(remote_path, otype, ...)
  }

  # Tell Python to track this artifact
  py_lamin$models$artifact$`_track_run_input`(py_object, is_run_input)

  conn
}
