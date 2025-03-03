#' Load a `.csv` file to a data frame
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [readr::read_csv()]
#'
#' @return A `data.frame`
#' @noRd
load_csv <- function(file, ...) {
  check_requires("Loading CSV files", "readr")
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
  check_requires("Loading TSV files", "readr")
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

#' Load a `.zarr` file to `AnnData`
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
#' @details
#' Row indexes are read as columns by [nanoparquet::read_parquet()]. If there
#' is a "__index_level_0__" then the results is converted to a `data.frame` and
#' the row names are set to "__index_level_0__".
#'
#' @return Either a `data.frame` if the data includes row names or a `tbl` if
#'   not
#' @noRd
load_parquet <- function(file, ...) {
  check_requires("Reading Parquet files", "arrow")

  df <- arrow::read_parquet(file, ...)

  # If there is a "__index_level_0__" column, convert to data.frame and
  # set row names
  if ("__index_level_0__" %in% colnames(df)) {
    row_names <- df[["__index_level_0__"]]
    df <- as.data.frame(df[, colnames(df) != "__index_level_0__"])
    rownames(df) <- row_names
  }

  df
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
  # NOTE: this is probably not the best solution
  check_requires("Loading MuData objects", "mudata", language = "Python")
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
    return(utils::browseURL(file, ...))
  }

  file
}

#' Load a JSON file
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to [jsonlite::fromJSON()]
#'
#' @return A list
#' @noRd
load_json <- function(file, ...) {
  jsonlite::fromJSON(file, ...)
}

#' Display an `.svg`, `.jpg`, `.png` or `.gif`
#'
#' @param file Path to the file to load
#' @param ... Additional arguments to pass to ...
#'
#' @return Display the image in the viewer if interactive mode is enabled,
#'   include it in document if in knitr or the path to the file otherwise
#' @noRd
load_image <- function(file, ...) {
  # If part of a knitr document, include the image
  if (is_knitr_notebook()) {
    ext <- tools::file_ext(file)

    if (knitr::is_latex_output() && ext == "svg") {
      check_requires("Displaying SVG images in LaTeX", "rsvg")
      pdf_file <- tempfile(fileext = ".pdf")
      return(rsvg::rsvg_pdf(file, pdf_file, ...))
    }

    return(knitr::include_graphics(file, ...))
  }

  # If interactive, show the image
  if (interactive()) {
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
  ".gif" = load_image,
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
#' Returns the file path if no in-memory form is found
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
    cli::cli_warn("Loading files of type {.val suffix} is not supported")
    return(file)
  } else {
    return(file_loader(file, ...))
  }
}
