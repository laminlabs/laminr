#' Import Python modules
#'
#' These function can be used to import LaminDB Python modules with additional
#' checks and nicer error messages.
#'
#' @param module The name of the Python module to import
#' @param check_instance Whether to check if the package is installed in the
#'   current LaminDB instance.
#'
#' @returns An object representing a Python package
#' @export
#'
#' @details
#'
#' - `import_lamindb()` - Import the main `lamindb` package. This is the
#'   starting point for interacting with a LaminDB instance.
#' - `import_bionty()` - Import the `bionty` module for accessing biological
#'   entities.
#' - `import_wetlab()` - Import the `wetlab` module for accessing wet lab
#'   entities.
#' - `import_clinicore()` - Import the `clincore` module for accessing clinical
#'   entities.
#' - `import_module()` - Import any Python module. This is mostly intended for
#'   internal use and should only be used if there is not a specific function
#'   for that module.
#'
#' @name importing
#' @order 99
#'
#' @examples
#' \dontrun{
#' # Import lamindb to start interacting with an instance
#' ln <- import_lamindb()
#'
#' # Import other LaminDB modules
#' bt <- import_bionty()
#' wl <- import_wetlab()
#' cc <- import_clinicore()
#'
#' # Import any Python module
#' np <- import_module("numpy")
#' }
import_module <- function(module, check_instance = FALSE) {
  if (check_instance) {
    check_instance_module(module)
  }
  check_requires(paste("Importing", module), module, language = "Python")

  tryCatch(
    reticulate::import(module),
    error = function(err) {
      cli::cli_abort(c(
        "Failed to connect to the Python {.pkg {module}} package,",
        "i" = "Run {.run reticulate::py_config()} and {.run reticulate::py_last_error()} for details"
      ))
    }
  )
}

#' @rdname importing
#' @order 2
#' @export
import_bionty <- function() {
  import_module("bionty", check_instance = TRUE)
}

#' @rdname importing
#' @order 3
#' @export
import_wetlab <- function() {
  import_module("wetlab", check_instance = TRUE)
}

#' @rdname importing
#' @order 4
#' @export
import_clinicore <- function() {
  import_module("clinicore", check_instance = TRUE)
}
