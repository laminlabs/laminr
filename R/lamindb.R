#' @rdname importing
#' @order 1
#' @export
import_lamindb <- function() {
  py_lamindb <- import_module("lamindb")

  tryCatch(
    {
      instance_settings <- py_lamindb$setup$settings$instance
      instance_slug <- paste0(instance_settings$owner, "/", instance_settings$name)
      set_default_instance(instance_slug)
    },
    error = function(err) {
      cli::cli_alert_danger(
        "No instance is loaded. Call {.code lamin_init()} or {.code lamin_connect()}"
      )
    }
  )

  reticulate::register_module_help_handler(
    "lamindb", lamindb_module_help_handler
  )

  # Avoid "no visible binding for global variable"
  self <- NULL # nolint object_usage_linter
  private <- NULL # nolint object_usage_linter

  wrap_python(
    py_lamindb,
    public = list(
      track = function(transform = NULL, params = NULL, new_run = NULL, path = NULL, log_to_file = NULL) {
        lamindb_track(private, transform, params, new_run, path, log_to_file)
      },
      finish = function(ignore_non_consecutive = NULL) {
        lamindb_finish(private, ignore_non_consecutive)
      }
    )
  )
}

lamindb_track <- function(private, transform = NULL, params = NULL, new_run = NULL, path = NULL, log_to_file = NULL) {
  if (is.null(path)) {
    path <- detect_path()
    if (is.null(path)) {
      cli::cli_abort(
        "Failed to detect the path to track. Please set the {.arg path} argument."
      )
    }
  }

  private$.py_object$track(
    transform = transform,
    params = params,
    new_run = new_run,
    path = path,
    log_to_file = log_to_file
  )
}

lamindb_finish <- function(private, ignore_non_consecutive = NULL) {
  tryCatch(
    private$.py_object$finish(
      ignore_non_consecutive = ignore_non_consecutive
    ),
    error = function(err) {
      py_err <- reticulate::py_last_error()
      if (py_err$type != "NotebookNotSaved") {
        cli::cli_abort(c(
          "Python {py_err$message}",
          "i" = "Run {.run reticulate::py_last_error()} for details"
        ))
      }
      # Please don't change the below without changing it in lamindb
      message <- gsub(".*NotebookNotSaved: (.*)$", "\\1", py_err$value) # nolint object_usage_linter
      cli::cli_inform(paste("NotebookNotSaved: {message}"))
    }
  )
}
