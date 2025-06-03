#' Set default instance
#'
#' Set the current default LaminDB instance
#'
#' @param instance_slug The slug (`<owner>/<name>`) for the default instance
#'
#' @returns Sets the `LAMINR_DEFAULT_INSTANCE` option
#' @noRd
set_default_instance <- function(instance_slug) {
  current_default <- get_default_instance()

  if (
    !is.null(current_default) && !is.null(instance_slug) &&
      !identical(instance_slug, current_default)
  ) {
    cli::cli_warn(c(
      paste(
        "The default instance has changed",
        "({.field Old default:} {.val {current_default}},",
        "{.field New default:} {.val {instance_slug}})"
      ),
      "i" = "It is recommended to start a new R session"
    ))
  }

  options(LAMINR_DEFAULT_INSTANCE = instance_slug)
}

#' Get default instance
#'
#' Get the slug for the current default LaminDB instance
#'
#' @returns The value of the `LAMINR_DEFAULT_INSTANCE` option
#' @noRd
get_default_instance <- function() {
  getOption("LAMINR_DEFAULT_INSTANCE")
}

#' Get current LaminDB user
#'
#' Get the currently logged in LaminDB user
#'
#' @returns The handle of the current LaminDB user, or `NULL` invisibly if no
#'   user is found
#' @export
#'
#' @details
#' This is done via [lamin_settings()] to avoid importing Python `lamindb`
get_current_lamin_user <- function() {
  settings <- lamin_settings()

  handle <- settings[["Current user"]]$handle

  if (is.null(handle)) {
    cli::cli_alert_danger("No current user")
    return(invisible(NULL))
  }

  handle
}

#' Get current LaminDB instance
#'
#' Get the currently connected LaminDB instance
#'
#' @returns The slug of the current LaminDB instance, or `NULL` invisibly if no
#'   instance is found
#' @export
#'
#' @details
#' This is done via a [lamin_settings()] to avoid importing Python `lamindb`
get_current_lamin_instance <- function() {
  settings <- lamin_settings()

  instance_slug <- settings[["Current instance"]]$value

  if (is.null(instance_slug)) {
    cli::cli_alert_danger("No current instance")
    return(invisible(NULL))
  }

  instance_slug
}

#' Check if we are in a knitr notebook
#'
#' @return `TRUE` if we are in a knitr notebook, `FALSE` otherwise
#'
#' @noRd
is_knitr_notebook <- function() {
  # If knitr is not available, assume that we are not in a notebook
  if (!requireNamespace("knitr", quietly = TRUE)) {
    return(FALSE)
  }

  # Check if we are in a notebook
  !is.null(knitr::opts_knit$get("out.format"))
}

#' Check if we are in RStudio
#'
#' @return `TRUE` if we are in RStudio, `FALSE` otherwise
#'
#' @noRd
is_rstudio <- function() {
  requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()
}

#' Detect path
#'
#' Find the path of the file where code is currently been run
#'
#' @return If found, path to the file relative to the working directory,
#'   otherwise `NULL`
#' @noRd
detect_path <- function() {
  # Based on various responses from https://stackoverflow.com/questions/47044068/get-the-path-of-current-script

  current_path <- NULL

  # Get path if in a running RMarkdown notebook
  if (is_knitr_notebook()) {
    current_path <- knitr::current_input()
  }

  # Get path if in a script run by `source("script.R")`
  source_trace <- R.utils::findSourceTraceback()
  if (is.null(current_path) && length(source_trace) > 0) {
    current_path <- names(source_trace)[1]
  }

  # Get path if in a script run by `Rscript script.R`
  if (is.null(current_path)) {
    cmd_args <- R.utils::commandArgs(asValues = TRUE)
    current_path <- cmd_args[["file"]]
  }

  # Get path if in a document in RStudio
  if (is.null(current_path) && is_rstudio()) {
    doc_context <- rstudioapi::getActiveDocumentContext()
    if (doc_context$id != "#console") {
      current_path <- doc_context$path
    }
  }

  # Normalise the path relative to the working directory
  if (!is.null(current_path)) {
    current_path <- R.utils::getRelativePath(current_path)
  }

  current_path
}

#' Standardise list columns
#'
#' Standardise list columns in a data frame
#'
#' @param df The data frame to standardise
#'
#' @returns A data frame with standardised list columns
#' @noRd
#'
#' @details
#' If there are any list columns in `df` any atomic values in them of length 1
#' are converted to a list of length 1. This is to make sure they are converted
#' to Python as lists of length 1, rather than scalars as `arrow` cannot handle
#' mixed list columns.
standardise_list_columns <- function(df) {
  list_columns <- which(purrr::map_lgl(df, is.list))
  for (list_idx in list_columns) {
    df[[list_idx]] <- purrr::map(df[[list_idx]], function(.item) {
      if (is.atomic(.item) && length(.item) == 1) {
        as.list(.item)
      } else {
        .item
      }
    })
  }

  df
}
