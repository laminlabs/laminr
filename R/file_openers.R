#' Open a connection to a TileDB-SOMA object
#'
#' @param uri URI for the object to open
#' @param ... Additional arguments to pass to `tiledbsoma::SOMAOpen()`
#'
#' @return A `tiledbsoma::SOMACollection` or `tiledbsoma::SOMAExperiment`
#' @noRd
open_tiledbsoma <- function(uri, ...) {
  check_requires(
    "Opening TileDB-SOMA artifacts", "tiledbsoma",
    extra_repos = "https://chanzuckerberg.r-universe.dev"
  )

  args <- list(...)
  args$uri <- uri

  do.call(get("SOMAOpen", asNamespace("tiledbsoma")), args)
}

#' Open a connection to a multi-file Parquet dataset
#'
#' @param sources A path or URI to the file(s) to open
#' @param ... Additional arguments to pass to [arrow::open_dataset()]
#'
#' @return A [arrow::Dataset]
#' @noRd
open_parquet <- function(sources, ...) {
  # Avoid loading {arrow} on MacOS due to a library conflict issue
  if (Sys.info()["sysname"] == "Darwin") {
    cli::cli_inform(c(
      "x" = "Opening a connection to Parquet files is currently not supported on MacOS",
      "i" = "Cache the file locally and load it instead"
    ))
    return(invisible(NULL))
  }

  check_requires("Opening Parquet datasets", "arrow")

  arrow::open_dataset(sources, ...)
}

file_openers <- list(
  "DataFrame" = open_parquet,
  "tiledbsoma" = open_tiledbsoma
)

#' Open a connection to a file
#'
#' Open a connection to a remote or backed file
#'
#' @param url URI for the file to connect to
#' @param otype The type of the file to connect to
#' @param ... Additional arguments to pass to the loader
#'
#' @return The loaded object
#' @noRd
open_file <- function(uri, otype = NULL, ...) {
  file_opener <- file_openers[[otype]]

  if (is.null(file_opener)) {
    cli::cli_warn("Opening remote files of type {.val {otype}} is not supported")
    return(uri)
  } else {
    return(file_opener(uri, ...))
  }
}
