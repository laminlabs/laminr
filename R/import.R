#' Import Python modules
#'
#' This function can be used to import **LaminDB** Python modules with
#' additional checks and nicer error messages.
#'
#' @param module The name of the Python module to import
#' @inheritDotParams require_module
#'
#' @returns An object representing a Python package
#' @export
#'
#' @details
#' Python dependencies are set using [require_module()] before importing
#' the module and used to create an ephemeral environment unless another
#' environment is found (see `vignette("versions", package = "reticulate")`).
#'
#' @seealso
#'
#' - [require_module()] and [reticulate::py_require()] for defining Python
#'   dependencies
#' - `vignette("versions", package = "reticulate")` for setting the Python
#'  environment to use (or online [here](https://rstudio.github.io/reticulate/articles/versions.html))
#'
#' @examples
#' \dontrun{
#' # Import lamindb to start interacting with an instance
#' ln <- import_module("lamindb")
#'
#' # Import lamindb with optional dependencies
#' ln <- import_module("lamindb", options = c("bionty", "wetlab"))
#'
#' # Import other LaminDB modules
#' bt <- import_module("bionty")
#' wl <- import_module("wetlab")
#' cc <- import_module("clinicore")
#'
#' # Import any Python module
#' np <- import_module("numpy")
#' }
import_module <- function(module, ...) {
  registry_modules <- c("bionty", "wetlab", "clinicore", "cellregistry", "omop")
  if (module %in% registry_modules) {
    check_instance_module(module)
  }

  if (module == "lamindb") {
    settings <- lamin_settings()
    init_lamindb_connection(settings)
  } else {
    require_module(module, ...)
  }
  check_requires(paste("Importing", module), module, language = "Python")

  py_module <- tryCatch(
    reticulate::import(module),
    error = function(err) {
      cli::cli_abort(c(
        "Failed to import the Python {.pkg {module}} package,",
        "i" = paste(
          "Run {.run reticulate::py_config()} and",
          "{.run reticulate::py_last_error()} for details"
        ),
        "x" = "Error message: {err}"
      ))
    }
  )

  if (module == "lamindb") {
    wrap_lamindb(py_module, settings)
  } else {
    py_module
  }
}
