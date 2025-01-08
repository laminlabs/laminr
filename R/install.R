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
install_lamindb <- function(..., envname = "r-lamindb", extra_packages = NULL,
                            new_env = identical(envname, "r-lamindb")) {

  if (new_env && reticulate::virtualenv_exists(envname)) {
    reticulate::virtualenv_remove(envname)
  }

  packages <- unique(c("lamindb", "ipython", extra_packages))

  reticulate::py_install(packages = packages, envname = envname, ...)

  env_type <-
    if (reticulate::virtualenv_exists(envname)) {
      "virtualenv"
    } else if (reticulate::condaenv_exists(envname)) {
      "conda"
    } else {
      cli::cli_abort(paste(
        "Neither a virtualenv or conda environment with the name {.val {envname}} exists.",
        "The installation may have failed."
      ))
    }

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

  invisible(NULL)
}
