#' Get file loader
#'
#' Get the correct file loader function based on a file suffix
#'
#' @param suffix String giving a file suffix
#'
#' @return Function that can be used to load the file
#' @noRd
get_file_loader <- function(suffix) {
  switch (suffix,
    ".h5ad" = load_h5ad,
    ".csv" = load_csv,
    ".tsv" = load_tsv,
    ".parquet" = load_parquet,
    cli::cli_abort("Loading files with suffix {.val suffix} is not supported")
  )
}

#' Load a H5AD file
#'
#' @param file Path to the file to load
#'
#' @return An `anndata::AnnDataR6` object
#' @noRd
load_h5ad <- function(file) {
  check_requires("Loading AnnData objects", "anndata")

  anndata::read_h5ad(file)
}

#' Load a CSV file
#'
#' @param file Path to the file to load
#'
#' @return A `data.frame`
#' @noRd
load_csv <- function(file) {
  read.csv(file)
}

#' Load a TSV file
#'
#' @param file Path to the file to load
#'
#' @return A `data.frame`
#' @noRd
load_tsv <- function(file) {
  read.delim(file)
}

#' Load a Parquet file
#'
#' @param file Path to the file to load
#'
#' @return A `data.frame`
#' @noRd
load_parquet <- function(file) {
  check_requires("Reading Parquet files", "nanoparquet")

  nanoparquet::read_parquet(file)
}
