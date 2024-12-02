# {laminr}: An R client for LaminDB

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/laminr)](https://CRAN.R-project.org/package=laminr)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**{laminr}** is an R client for [LaminDB](https://lamin.ai). If you are new to LaminDB, please read this [introduction](https://docs.lamin.ai/introduction).

- Connect to a LaminDB instance: `db <- connect()`
- Track scripts and notebooks as transforms: `db$track()`
- Get records by UID: `artifact <- db$Artifact$get()`
- Cache artifacts locally: `artifact$cache()`
- Load artifacts into memory for a broad range of storage formats: `artifact$load()`
- Create artifacts from data frames, paths, and `AnnData` objects: `db$Artifact$from_path()`
- Delete records: `artifact$delete()`

See the development roadmap for more details (`vignette("development", package = "laminr")`).

## Installation

Get started with **{laminr}** by installing the package from CRAN:

```r
install.packages("laminr")
```

You will also need to install the `lamindb` Python package:

```bash
pip install 'lamindb[aws,bionty,wetlab]>=0.77.2'
```

### Additional packages

Some functionality requires additional packages. To install all of these use:

```r
install.packages("laminr", dependencies = TRUE)
```

This will also install these package for the following tasks:

- **{anndata}** - Native `AnnData` support in R
- **{nanoparquet}** - Reading `.parquet` files
- **{readr}** - Reading CSV/TSV files
- **{reticulate}** - Functionality that requires the Python `lamindb` package
- **{rsvg}** - Reading SVG files
- **{s3}** - Fetching datasets from AWS S3

If you choose not to install all packages now you will be prompted to do so whenever one is required.

## Getting started

The best way to get started with **{laminr}** is to explore the package vignettes (available at [laminr.lamin.ai](https://laminr.lamin.ai)):

- **Get started**: Learn the basics and explore practical examples (`vignette("laminr", package = "laminr")`).
- **Package Architecture**: Get a better understanding of how **{laminr}** works (`vignette("architecture", package = "laminr")`).

For information on specific modules and functionalities, check out the following vignettes:

- **Core Module**: Learn about the core registries available in a LaminDB instance (`vignette("module_core", package = "laminr")`).
- **Bionty Module**: Explore the bionty module for biology-related entities (`vignette("module_bionty", package = "laminr")`).
