#' Import lamindb
#'
#' Import the `lamindb` Python package
#'
#' @returns An object representing the `lamindb` Python package
#' @export
#'
#' @examples
#' \dontrun{
#' ln <- import_lamindb()
#' }
import_lamindb <- function() {
  py_lamindb <- tryCatch(
    reticulate::import("lamindb"),
    error = function(err) {
      cli::cli_abort(c(
        "Failed to connect to the Python {.pkg lamindb} package,",
        "i" = "Run {.run reticulate::py_config()} and {.run reticulate::py_last_error()} for details"
      ))
    }
  )

  wrap_python(
    py_lamindb,
    public = list(
      track = lamindb_track,
      finish = lamindb_finish
    )
  )
}

lamindb_track <- function(transform = NULL, params = NULL, new_run = NULL, path = NULL, log_to_file = NULL) {
  if (is.null(path)) {
    path <- detect_path()
    if (is.null(path)) {
      cli::cli_abort(
        "Failed to detect the path to track. Please set the {.arg path} argument."
      )
    }
  }

  private$.py_object[['track']](
    transform = transform,
    params = params,
    new_run = new_run,
    path = path,
    log_to_file = log_to_file
  )
}

lamindb_finish <- function(ignore_non_consecutive = NULL) {
  tryCatch(
    private$.py_object[['finish']](
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
      message <- gsub(".*NotebookNotSaved: (.*)$", "\\1", py_err$value)
      cli::cli_inform(paste("NotebookNotSaved: {message}"))
    }
  )
}

#' Import bionty
#'
#' Import the `bionty` Python package
#'
#' @returns An object representing the `bionty` Python package
#' @export
#'
#' @examples
#' \dontrun{
#' bt <- import_bionty()
#' }
import_bionty <- function() {
  check_requires("Importing bionty", "bionty", language = "Python")

  tryCatch(
    reticulate::import("bionty"),
    error = function(err) {
      cli::cli_abort(c(
        "Failed to connect to the Python {.pkg bionty} package,",
        "i" = "Run {.run reticulate::py_config()} and {.run reticulate::py_last_error()} for details"
      ))
    }
  )
}
