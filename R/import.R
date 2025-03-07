#' Import Python modules
#'
#' This function can be used to import LaminDB Python modules with additional
#' checks and nicer error messages.
#'
#' @param module The name of the Python module to import
#'
#' @returns An object representing a Python package
#' @export
#'
#' @examples
#' \dontrun{
#' # Import lamindb to start interacting with an instance
#' ln <- import_module("lamindb")
#'
#' # Import other LaminDB modules
#' bt <- import_module("bionty")
#' wl <- import_module("wetlab")
#' cc <- import_module("clincore")
#'
#' # Import any Python module
#' np <- import_module("numpy")
#' }
import_module <- function(module) {
  if (module == "lamindb") {
    return(import_lamindb())
  }

  registry_modules <- c("bionty", "wetlab", "clinicore")
  if (module %in% registry_modules) {
    check_instance_module(module)
  }

  check_requires(paste("Importing", module), module, language = "Python")

  tryCatch(
    reticulate::import(module),
    error = function(err) {
      cli::cli_abort(c(
        "Failed to import the Python {.pkg {module}} package,",
        "i" = "Run {.run reticulate::py_config()} and {.run reticulate::py_last_error()} for details",
        "x" = "Error message: {err}"
      ))
    }
  )
}
