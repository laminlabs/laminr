#' Load a `.csv` file to a data frame
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [readr::read_csv()]
#'
#' @return A `data.frame`
#' @noRd
load_csv <- function(file, ...) {
  check_requires("Reading CSV files", "readr")
  readr::read_csv(file, ...)
}

#' Load a `.tsv` file to a data frame
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [readr::read_tsv()]
#'
#' @return A `data.frame`
#' @noRd
load_tsv <- function(file, ...) {
  check_requires("Reading TSV files", "readr")
  readr::read_tsv(file, ...)
}

#' Load an `.h5ad` file to `AnnData`
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [anndata::read_h5ad()]
#'
#' @return An `anndata::AnnDataR6` object
#' @noRd
load_h5ad <- function(file, ...) {
  check_requires("Loading AnnData objects", "anndata")
  anndata::read_h5ad(file, ...)
}

#' Load an `.zarr` file to `AnnData`
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to `anndata::read_zarr()`
#'
#' @return The path to the file
#' @noRd
load_anndata_zarr <- function(file, ...) {
  cli_warn("Loading AnnData Zarr files is not yet supported")
  file
}

#' Load a Parquet file
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [nanoparquet::read_parquet()]
#'
#' @return A data frame
#' @noRd
load_parquet <- function(file) {
  check_requires("Reading Parquet files", "nanoparquet")
  nanoparquet::read_parquet(file)
}

#' Load an `.fcs` file to `AnnData`
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to ...
#'
#' @return An `anndata::AnnDataR6` object
#' @noRd
load_fcs <- function(file, ...) {
  cli_warn("Loading FCS files is not yet supported")
  file
}

#' Load an `.h5mu` file to `MuData`
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to `mudata::read_h5mu()`
#'
#' @return A `MuData` object
#' @noRd
load_h5mu <- function(file, ...) {
  # Note: this is probably not the best solution
  check_requires("Loading MuData objects", "reticulate")
  mudata <- reticulate::import("mudata")

  mudata$read_h5mu(file, ...)
}

#' Maybe display an HTML file
#'
#' If interactive mode is enabled, open the file in the default browser.
#' Otherwise just return the path to the file.
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [utils::browseURL()]
#'
#' @return NULL if interactive mode is enabled, the path to the file otherwise
#' @noRd
load_html <- function(file, ...) {
  if (is_knitr_notebook()) {
    lines <- readLines(file)
    return(knitr::raw_html(paste(lines, collapse = "\n")))
  }

  if (interactive()) {
    check_requires("Opening HTML files", "utils")
    return(utils::browseURL(file, ...))
  }

  return(file)
}

#' Load a JSON file
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [jsonlite::fromJSON()]
#'
#' @return A list
#' @noRd
load_json <- function(file, ...) {
  check_requires("Reading JSON files", "jsonlite")
  jsonlite::fromJSON(file, ...)
}

#' Display an `.svg`, `.jpg`, `.png` or `.gif` in the viewer
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [...]
#'
#' @return NULL
#' @noRd
load_image <- function(file, ...) {
  # if part of a knitr document, include the SVG
  if (is_knitr_notebook()) {
    ext <- tools::file_ext(file)

    if (knitr::is_latex_output() && ext == "svg") {
      check_requires("Displaying SVG images in LaTeX", "rsvg")
      pdf_file <- tempfile(fileext = ".pdf")
      return(rsvg::rsvg_pdf(file, pdf_file, ...))
    }

    return(knitr::include_graphics(file, ...))
  }

  if (interactive()) {
    check_requires("Displaying images", "utils")
    return(utils::browseURL(file, ...))
  }

  file
}

#' Load an RDS file
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [readRDS()]
#'
#' @return The object stored in the RDS file
#' @noRd
load_rds <- function(file, ...) {
  readRDS(file, ...)
}

#' Load a YAML file
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [yaml::yaml.load_file()]
#'
#' @return A list
#' @noRd
load_yaml <- function(file, ...) {
  check_requires("Reading YAML files", "yaml")
  yaml::yaml.load_file(file, ...)
}

file_loaders <- list(
  ".csv" = load_csv,
  ".fcs" = load_fcs,
  ".h5ad" = load_h5ad,
  ".h5mu" = load_h5mu,
  ".html" = load_html,
  ".jpg" = load_image,
  ".json" = load_json,
  ".parquet" = load_parquet,
  ".png" = load_image,
  ".rds" = load_rds,
  ".svg" = load_image,
  ".tsv" = load_tsv,
  ".yaml" = load_yaml,
  ".zarr" = load_anndata_zarr
)

#' Load a file into memory
#'
#' Returns the filepath if no in-memory form is found
#'
#' @param file Path to the file to load
#' @param suffix The file extension to use for loading
#' @param ... Additional arguments to pass to the loader
#'
#' @return The loaded object
#' @noRd
#'
#' @importFrom tools file_ext
load_file <- function(file, suffix = NULL, ...) {
  if (is.null(suffix)) {
    suffix <- paste0(".", tools::file_ext(file))
  }

  file_loader <- file_loaders[[suffix]]

  if (is.null(file_loader)) {
    return(file)
  } else {
    return(file_loader(file, ...))
  }
}
