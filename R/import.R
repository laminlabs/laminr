#' Import Python modules
#'
#' This function can be used to import LaminDB Python modules with additional
#' checks and nicer error messages.
#'
#' @param module The name of the Python module to import
#' @param options A vector of optional dependencies for the module that is being
#'   imported
#'
#' @returns An object representing a Python package
#' @export
#'
#' @details
#' If another Python environment is not found (see <https://rstudio.github.io/reticulate/articles/versions.html>),
#' Python dependencies will be set using [reticulate::py_require()] before
#' importing the module. The `options` argument is only applicable the first
#' time a module is imported and will result in a warning if a requirement for
#' that module has already been set. Setting `options = c("opt1", "opt2")`
#' results in `module[opt1,opt2]`.
#'
#' @seealso [reticulate::py_require()] and `vignette("versions", package = "reticulate")`
#'   for details on setting the Python environment
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
import_module <- function(module, options = NULL) {
  registry_modules <- c("bionty", "wetlab", "clinicore", "cellregistry", "omop")
  if (module %in% registry_modules) {
    check_instance_module(module)
  }

  require_module(module, options = options)
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
    wrap_lamindb(py_module)
  } else {
    py_module
  }
}
