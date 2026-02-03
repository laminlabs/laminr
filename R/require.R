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
#' @param silent Whether to suppress the message showing what has been required
#'
#' @returns The result of [reticulate::py_require]
#' @export
#'
#' @details
#' Python dependencies are set using [reticulate::py_require()]. If a connection
#' to Python is already initialized and the requested module is already in the
#' list of requirements then a further call to [reticulate::py_require()] will
#' not be made to avoid errors/warnings. This means that required versions etc.
#' need to be set before Python is initialized.
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
#' require_module("lamindb", version = ">=2.0.0")
#'
#' # Require require lamindb with options
#' require_module("lamindb", options = c("dev"))
#'
#' # Require the development version of lamindb from GitHub
#' require_module("lamindb", source = "git+https://github.com/laminlabs/lamindb.git")
#'
#' # Require lamindb with a specific Python version
#' require_module("lamindb", python_version = "3.12")
#' }
require_module <- function(module, options = NULL, version = NULL,
                           source = NULL, python_version = NULL,
                           silent = FALSE) {
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

  if (!isTRUE(silent)) {
    msg <- "Requiring {.pkg {requirement}}"
    if (!is.null(python_version)) {
      msg <- paste(msg, "with Python version {.pkg {python_version}}")
    }
    cli::cli_alert_info(msg)
  }

  reticulate::py_require(requirement, python_version = python_version)
}

#' Require lamindb
#'
#' Require the lamindb Python module
#'
#' @param silent Whether to suppress messages showing what has been required
#'
#' @noRd
#'
#' @details
#' Functions requiring the `lamindb` Python module should make sure this is
#' called before attempting to use it (either directly, or via
#' `import_module()`).
require_lamindb <- function(silent = FALSE) {
  if (reticulate::py_available() && reticulate::py_module_available("lamindb")) {
    return(invisible(NULL))
  }

  # Minimal scipy requirement to avoid trying to compile scipy 1.6
  require_module("scipy", version = ">=1.7", silent = TRUE)

  laminr_lamindb_version <- trimws(tolower(Sys.getenv("LAMINR_LAMINDB_VERSION")))
  laminr_lamindb_options <- Sys.getenv("LAMINR_LAMINDB_OPTIONS")
  if (laminr_lamindb_options != "") {
    laminr_lamindb_options <- trimws(unlist(strsplit(laminr_lamindb_options, ",")))
    if (!isTRUE(silent)) {
      cli::cli_alert_info(
        "Requiring {.pkg lamindb} options {.val {laminr_lamindb_options}}"
      )
    }
  } else {
    laminr_lamindb_options <- NULL
  }

  if (laminr_lamindb_version %in% c("release", "latest", "")) {
    require_module(
      "lamindb",
      options = laminr_lamindb_options,
      version = ">=2.0.0",
      python_version = ">=3.10,<3.14",
      silent = silent
    )
  } else if (laminr_lamindb_version %in% c("github", "devel")) {
    if (!isTRUE(silent)) {
      cli::cli_alert_info(
        "Requiring the development version of {.pkg lamindb}"
      )
    }

    reticulate::py_require(python_version = ">=3.10,<3.14")

    # Also require matching devel versions of other lamin packages
    require_module(
      "lamindb_setup",
      options = "aws",
      source = "git+https://github.com/laminlabs/lamindb.git#subdirectory=sub/lamindb-setup",
      silent = silent
    )
    require_module(
      "lamin_utils",
      source = "git+https://github.com/laminlabs/lamin-utils.git",
      silent = silent
    )
    require_module(
      "lamin_cli",
      source = "git+https://github.com/laminlabs/lamindb.git#subdirectory=sub/lamin-cli",
      silent = silent
    )
    require_module(
      "bionty",
      source = "git+https://github.com/laminlabs/lamindb.git#subdirectory=sub/bionty",
      silent = silent
    )
    require_module(
      "lamindb",
      options = laminr_lamindb_options,
      source = "git+https://github.com/laminlabs/lamindb.git",
      silent = silent
    )
  } else {
    # Remove leading v from version string
    laminr_lamindb_version <- gsub("^v", "", laminr_lamindb_version)
    # Assume an exact version if string starts with a number
    if (grepl("^[0-9]", laminr_lamindb_version)) {
      laminr_lamindb_version <- paste0("==", laminr_lamindb_version)
    }

    if (!isTRUE(silent)) {
      cli::cli_alert_info(
        "Requiring {.pkg lamindb} version {.val {laminr_lamindb_version}}"
      )
    }

    require_module(
      "lamindb",
      options = laminr_lamindb_options,
      version = laminr_lamindb_version,
      silent = silent
    )
  }
}
