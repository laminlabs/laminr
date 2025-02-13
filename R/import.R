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
  tryCatch(
    reticulate::import("lamindb"),
    error = function(err) {
      cli::cli_abort(c(
        "Failed to connect to the Python {.pkg lamindb} package,",
        "i" = "Run {.run reticulate::py_config()} and {.run reticulate::py_last_error()} for details"
      ))
    }
  )
}
