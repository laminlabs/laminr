#' Install LaminDB
#'
#' Create a Python environment containing **lamindb** or install **lamindb**
#' into an existing environment.
#'
#' @param ... Additional arguments passed to `reticulate::py_install()`
#' @param envname String giving the name of the environment to install packages
#'   into
#' @param extra_packages A vector giving the names of additional Python packages
#'   to install
#' @param new_env Whether to remove any existing `virtualenv` with the same name
#'   before creating a new one with the requested packages
#' @param use Whether to attempt use the new environment
#'
#' @return `NULL`, invisibly
#' @export
#'
#' @details
#' See `vignette("setup", package = "laminr")` for further details on setting up
#' a Python environment
#'
#' @examples
#' \dontrun{
#' install_lamindb()
#'
#' # Add additional packages to the environment
#' install_lamindb(extra_packages = c("bionty", "wetlab"))
#'
#' # Install into a different environment
#' install_lamindb(envvname = "your-env")
#' }
old_install_lamindb <- function(
  ...,
  envname = "r-lamindb",
  extra_packages = NULL,
  new_env = identical(envname, "r-lamindb"),
  use = TRUE
) {
  if (new_env && reticulate::virtualenv_exists(envname)) {
    reticulate::virtualenv_remove(envname)
  }

  packages <- unique(c("lamindb>=1.2", "ipython", extra_packages))

  reticulate::py_install(packages = packages, envname = envname, ...)

  env_type <- if (reticulate::virtualenv_exists(envname)) {
    "virtualenv"
  } else if (reticulate::condaenv_exists(envname)) {
    "conda"
  } else {
    cli::cli_abort(paste(
      "Neither a virtualenv or conda environment with the name {.val {envname}} exists.",
      "The installation may have failed."
    ))
  }

  if (isTRUE(use)) {
    tryCatch(
      switch(
        env_type,
        virtualenv = reticulate::use_virtualenv(envname),
        conda = reticulate::use_condaenv(envname)
      ),
      error = function(err) {
        cli::cli_warn(paste(
          "Unable to attach to the {.val {envname}} {env_type} environment.",
          "Try starting a new R session before using {.pkg laminr}."
        ))
      }
    )
  }

  invisible(NULL)
}

#' Require a Python module
#'
#' This function can be used to require that Python modules are available for
#' \pkg{laminr}  with additional checks and nicer error messages.
#'
#' @param module The name of the Python module to require
#' @param options A vector of defined optional dependencies for the module that
#'   is being required
#' @param version A string specifying the version of the module to require
#' @param source A source for the module requirement, for example
#'   `git+https://github.com/owner/module.git`
#' @param python_version A string defining the Python version to require. Passed
#'   to [reticulate::py_require()]
#'
#' @returns The result of [reticulate::py_require]
#' @export
#'
#' @details
#' Python dependencies are set using [reticulate::py_require()]. If a connection
#' to Python is already initialized and the requested module is already in the
#' list of requirements then a further call to [reticulate::py_require()] will
#' not be made to avoid errors/warnings. This means that required versions etc.
#' need to be set before Python is initalized.
#'
#' ## Arguments
#'
#' - Setting `options = c("opt1", "opt2")` results in `"module[opt1,opt2]"`
#' - Setting `version = ">=1.0.0"` results in `"module>=1.0.0"`
#' - Setting `source = "my_source"` results in `"module @ my_source"`
#' - Setting all of the above results in `"module[opt1,opt2]>=1.0.0 @ my_source"`
#'
#' @seealso [reticulate::py_require()]
#'
#' @examples
#' \dontrun{
#' # Require lamindb
#' require_module("lamindb")
#'
#' # Require a specific version of lamindb
#' require_module("lamindb", version = ">=1.2")
#'
#' # Require require lamindb with options
#' require_module("lamindb", options = c("bionty", "wetlab"))
#'
#' # Require the development version of lamindb from GitHub
#' require_module("lamindb", source = "git+https://github.com/laminlabs/lamindb.git")
#'
#' # Require lamindb with a specific Python version
#' require_module("lamindb", python_version = "3.12")
#' }
require_module <- function(module, options = NULL, version = NULL,
                           source = NULL, python_version = NULL) {
  if (length(module) > 1) {
    cli::cli_abort("Only one module can be required at a time")
  }

  # Do nothing if Python is initialized and the module is already required
  if (reticulate::py_available()) {
    current_requirements <- reticulate::py_require()
    # Use startsWith to match packages with versions or options
    if (any(startsWith(current_requirements$packages, module))) {
      return(invisible(NULL))
    }
  }

  requirement <- module
  if (!is.null(options)) {
    requirement <- paste0(requirement, "[", paste0(options, collapse = ","), "]")
  }
  if (!is.null(version)) {
    requirement <- paste0(requirement, version)
  }
  if (!is.null(source)) {
    requirement <- paste(requirement, "@", source)
  }

  reticulate::py_require(requirement, python_version = python_version)
}

require_lamindb <- function() {
  require_module("lamindb", version = ">=1.2", python_version = ">=3.10,<3.14")
}
