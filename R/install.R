#' Install LaminDB
#'
#' @description
#' `r lifecycle::badge('deprecated')`
#'
#' This function is deprecated and is replaced by a system which automatically
#' installs packages as needed. See [import_module()], [require_module()] and
#' [reticulate::py_require()] for details.
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
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' # Using import_module() will automatically install packages
#' ln <- import_module("lamindb")
#'
#' # Create a Python environment with lamindb
#' # This approach is deprecated
#' install_lamindb()
#'
#' # Add additional packages to the environment
#' install_lamindb(extra_packages = c("bionty", "wetlab"))
#'
#' # Install into a different environment
#' install_lamindb(envvname = "your-env")
#' }
install_lamindb <- function(
    ...,
    envname = "r-lamindb",
    extra_packages = NULL,
    new_env = identical(envname, "r-lamindb"),
    use = TRUE) {
  lifecycle::deprecate_warn(
    "1.1.0",
    "install_lamindb()",
    details = cli::format_message(
      "Using {.fun import_module} will now automatically install packages"
    )
  )

  if (new_env && reticulate::virtualenv_exists(envname)) {
    reticulate::virtualenv_remove(envname)
  }

  packages <- unique(c("lamindb>=2.0a2", "ipython", extra_packages))

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
      switch(env_type,
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
