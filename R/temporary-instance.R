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

  py_lamindb <- import_module("lamindb")

  # Get the current instance to reset later
  current_instance <- get_current_lamin_instance(silent = TRUE)
  cli::cli_alert_info("Current instance: {.val {current_instance}}")
  py_lamindb$setup$disconnect()

  # Create the temporary storage for this instance
  temp_storage <- file.path(tempdir(), name)

  if (!is.null(modules)) {
    for (module in modules) {
      require_module(module, silent = TRUE)
    }

    check_requires(
      "Initialising a database with these modules", modules,
      language = "Python"
    )
    modules_str <- paste(modules, collapse = ",")
  } else {
    modules_str <- NULL
  }

  py_lamindb$setup$init(
    storage = temp_storage,
    name = name,
    modules = modules_str
  )

  temp_instance <- get_current_lamin_instance(silent = TRUE)
  cli::cli_alert_info("Temporary instance: {.val {temp_instance}}")

  # Add the clean up handler to the environment
  withr::defer(
    {
      # Disconnect from the temporary instance
      py_lamindb$setup$disconnect()

      # Delete the temporary instance
      py_lamindb$setup$delete(temp_instance, force = TRUE, require_empty = FALSE)

      # Try to reconnect to the previous instance
      if (!is.null(current_instance)) {
        tryCatch(
          {
            py_lamindb$connect(current_instance)
          },
          error = function(err) {
            cli::cli_warn(c(
              "Failed to reconnect to the previous LaminDB instance ({.val {current_instance}})",
              "x" = "Error message: {err}"
            ))
          }
        )
      }
    },
    envir = envir
  )
}
