wrap_lamindb <- function(py_lamindb, settings) {
  lamin_version <- reticulate::py_get_attr(py_lamindb, "__version__")
  lamin_version_clean <- sub("([a-zA-Z].*)", "", lamin_version) # Remove pre-release versions, e.g. 1.0a5 -> 1.0
  min_version <- "1.2"
  if (utils::compareVersion(min_version, lamin_version_clean) == 1) {
    cli::cli_abort(
      paste(
        "This version of {.pkg laminr} requires Python {.pkg lamindb} >= v{min_version}.",
        "You have {.pkg lamindb} v{lamin_version}."
      )
    )
  }

  instance_slug <- settings$instance$slug
  if (!is.null(instance_slug)) {
    # Warn if instance modules are not available
    instance_modules <- settings$instance$modules
    check_requires(
      cli::format_inline("Some functionality in the {.val {instance_slug}} instance"),
      instance_modules,
      language = "Python",
      alert = "message",
      info = c("!" = "This should be done {.emph before} connecting to any instance")
    )

    tryCatch(
      storage <- reticulate::py_repr(py_lamindb$settings$storage), # nolint object_usage_linter
      error = function(err) {
        cli::cli_abort(
          c(
            paste(
              "Failed to identify storage for instance {.val {instance_slug}}.",
              "The directory for this instance may have been deleted."
            ),
            "i" = paste(
              "Restart your R session and use {.code lamin_connect()} to",
              "connect to another instance"
            ),
            "x" = "Error message: {err}"
          ),
          call = rlang::caller_env(4)
        )
      }
    )
  }

  reticulate::register_module_help_handler(
    "lamindb",
    lamindb_module_help_handler
  )

  wrap_python(
    py_lamindb,
    public = list(
      track = wrap_with_py_arguments(lamindb_track, py_lamindb$track),
      finish = wrap_with_py_arguments(lamindb_finish, py_lamindb$finish)
    )
  )
}

lamindb_track <- function(self, ...) {
  args <- list(...)

  if (is.null(args$path)) {
    path <- detect_path()
    if (is.null(path)) {
      cli::cli_abort(
        "Failed to detect the path to track. Please set the {.arg path} argument."
      )
    }
    args$path <- path
  }

  py_object <- unwrap_python(self)
  unwrap_args_and_call(py_object$track, args)
}

lamindb_finish <- function(self, ...) {
  py_object <- unwrap_python(self)

  run <- py_object$context$run
  if (!is.null(run)) {
    settings <- py_object$settings

    env_dir <- file.path(settings$cache_dir, "environments")

    if (!dir.exists(env_dir)) {
      dir.create(env_dir)
    }

    run_dir <- file.path(env_dir, paste0("run_", run$uid))

    if (!dir.exists(run_dir)) {
      dir.create(run_dir)
    }

    r_environment_file <- file.path(run_dir, "r_environment.txt")

    tryCatch(
      {
        r_environment <- get_r_environment()
        writeLines(r_environment, r_environment_file)
      },
      error = function(err) {
        cli::cli_warn(
          c(
            "Failed to write the R environment file",
            "i" = "Please reach out via GitHub or Slack if you need help.",
            "x" = "Error message: {err}"
          )
        )
      }
    )
  }

  tryCatch(
    unwrap_args_and_call(py_object$finish, list(...)),
    error = function(err) {
      py_err <- reticulate::py_last_error()
      if (py_err$type != "NotebookNotSaved") {
        cli::cli_abort(c(
          "Python {py_err$message}",
          "i" = "Run {.run reticulate::py_last_error()} for details"
        ))
      }
      # Please don't change the below without changing it in lamindb
      message <- gsub(".*NotebookNotSaved: (.*)$", "\\1", py_err$value) # nolint object_usage_linter
      cli::cli_inform(paste("NotebookNotSaved: {message}"))
    }
  )
}

#' Initialise lamindb connection
#'
#' Performs setup in preparation for connecting to a lamindb instance that must
#' be done _before_ importing the Python `lamimdb` module.
#'
#' @param settings A list of LaminDB settings returned by [lamin_settings()]
#'
#' @returns NULL, invisibly
#' @noRd
init_lamindb_connection <- function(settings) {
  require_lamindb()

  instance_slug <- settings$instance$slug
  if (is.null(instance_slug)) {
    cli::cli_abort(
      "No instance is loaded. Call {.code lamin_init()} or {.code lamin_connect()}"
    )
    return(invisible(NULL))
  }

  if (is.null(get_default_instance())) {
    instance_modules <- settings$instance$modules
    for (module in instance_modules) {
      require_module(module)
    }

    set_default_instance(instance_slug)
  }

  if (getOption("LAMINR_COLORS_DISABLED", is_knitr_notebook())) {
    # Disable Python ASCII color codes in knitr
    py_lamin_utils <- import_module("lamin_utils", silent = TRUE)
    py_lamin_utils[["_logger"]]$LEVEL_TO_COLORS <- setNames(list(), character(0))
    py_lamin_utils[["_logger"]]$RESET_COLOR <- ""
    options(LAMINR_COLORS_DISABLED = TRUE)
  }

  invisible()
}
