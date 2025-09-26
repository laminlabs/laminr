#' Use a temporary LaminDB instance
#'
#' Create and connect to a temporary LaminDB instance to use for the current
#' session. This function is primarily intended for developers to use during
#' testing and documentation but can also be useful for users to debug issues
#' or create reproducible examples.
#'
#' @param name A name for the temporary instance
#' @param modules A vector of modules to include (e.g. "bionty")
#' @param add_timestamp Whether to append a time stamp to `name` to make it
#'   unique
#' @param envir An environment passed to [withr::defer()]
#'
#' @details
#' This function creates and connects to a temporary LaminDB instance. A
#' temporary storage folder is created and used to initialize a new instance. An
#' exit handler is registered with [withr::defer()] that deletes the instance
#' and storage, then reconnects to the previous instance when `envir` finishes.
#'
#' Switching to a temporary instance is not possible when another instance is
#' already connected.
#'
#' @export
use_temporary_instance <- function(name = "laminr-temp", modules = NULL,
                                   add_timestamp = TRUE, envir = parent.frame()) {
  if (isTRUE(add_timestamp)) {
    # Add a time stamp to get a unique name
    timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
    name <- paste0(name, "-", timestamp)
  }

  # Get the current instance to reset later
  current_instance <- laminr::get_current_lamin_instance()

  # Create the temporary storage for this instance
  temp_storage <- file.path(tempdir(), name)

  # Initialise the temporary instance
  callr::r(
    function(storage, name, modules) {
      require_lamindb(silent = TRUE)

      if (!is.null(modules)) {
        for (module in modules) {
          require_module(module, silent = TRUE)
        }
      }
      lc <- import_module("lamin_cli", silent = TRUE)

      if (!is.null(modules)) {
        check_requires(
          "Initialising a database with these modules", modules,
          language = "Python"
        )
        modules_str <- paste(modules, collapse = ",")
      } else {
        modules_str <- NULL
      }

      lc$init(
        storage = storage,
        name = name,
        modules = modules_str
      )
    },
    args = list(storage = temp_storage, name = name, modules = modules),
    package = "laminr"
  ) |>
    print_stdout()

  # Add the clean up handler to the environment
  withr::defer(
    {
      lc <- laminr::import_module("lamin_cli", silent = TRUE)

      # Delete the temporary instance
      lc$delete(name, force = TRUE)
      unlink(temp_storage, recursive = TRUE, force = TRUE)

      # Reconnect to the previous instance
      lc$connect(current_instance)
    },
    envir = envir
  )
}
