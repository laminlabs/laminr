wrap_lamindb <- function(py_lamindb) {
  check_requires("Importing lamindb", "lamindb", language = "Python")

  instance_slug <- NULL
  tryCatch(
    {
      instance_settings <- py_lamindb$setup$settings$instance
      instance_slug <- paste0(instance_settings$owner, "/", instance_settings$name)
      set_default_instance(instance_slug)
    },
    error = function(err) {
      cli::cli_alert_danger(
        "No instance is loaded. Call {.code lamin_init()} or {.code lamin_connect()}"
      )
    }
  )

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

  if (!is.null(instance_slug)) {
    tryCatch(
      storage <- reticulate::py_repr(py_lamindb$settings$storage), # nolint object_usage_linter
      error = function(err) {
        cli::cli_abort(c(
          paste(
            "Failed to identify storage for instance {.val {instance_slug}}.",
            "The directory for this instance may have been deleted."
          ),
          "i" = paste(
            "Restart your R session and use {.code lamin_connect()} to",
            "connect to another instance"
          ),
          "x" = "Error message: {err}"
        ), call = rlang::caller_env(4))
      }
    )
  }

  reticulate::register_module_help_handler(
    "lamindb", lamindb_module_help_handler
  )

  # Avoid "no visible binding for global variable"
  self <- NULL # nolint object_usage_linter
  private <- NULL # nolint object_usage_linter

  wrap_python(
    py_lamindb,
    public = list(
      track = function(transform = NULL, project = NULL, params = NULL, new_run = NULL, path = NULL) {
        lamindb_track(private, transform, project, params, new_run, path)
      },
      finish = function(ignore_non_consecutive = NULL) {
        lamindb_finish(private, ignore_non_consecutive)
      }
    )
  )
}

lamindb_track <- function(private, transform = NULL, project = NULL, params = NULL, new_run = NULL,
                          path = NULL) {
  if (is.null(path)) {
    path <- detect_path()
    if (is.null(path)) {
      cli::cli_abort(
        "Failed to detect the path to track. Please set the {.arg path} argument."
      )
    }
  }

  private$.py_object$track(
    transform = transform,
    project = project,
    params = params,
    new_run = new_run,
    path = path,
  )
}

lamindb_finish <- function(private, ignore_non_consecutive = NULL) {
  run <- private$.py_object$context$run
  if (!is.null(run)) {
    settings <- private$.py_object$settings

    env_dir <- file.path(settings$cache_dir, "environments")

    if (!dir.exists(env_dir)) {
      dir.create(env_dir)
    }

    run_dir <- file.path(env_dir, paste0("run_", run$uid))

    if (!dir.exists(run_dir)) {
      dir.create(run_dir)
    }

    pkgs <- get_loaded_packages()
    pkg_repos <- get_package_repositories(pkgs)

    withr::with_options(list(repos = unique(c(pkg_repos, getOption("repos")))), {
      pak::lockfile_create(
        pkg = pkgs,
        lockfile = file.path(run_dir, "r_pak_lockfile.json")
      )
    })
  }

  tryCatch(
    private$.py_object$finish(
      ignore_non_consecutive = ignore_non_consecutive
    ),
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
