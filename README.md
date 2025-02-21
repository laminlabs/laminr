# {laminr}: An R client for LaminDB

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/laminr)](https://CRAN.R-project.org/package=laminr)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**{laminr}** is an R client for [LaminDB](https://lamin.ai). If you are new to LaminDB, please read this [introduction](https://docs.lamin.ai/introduction).

- Connect to a LaminDB instance: `ln <- import_lamindb()`
- Track scripts and notebooks as transforms: `ln$track()`
- Get records by UID: `artifact <- ln$Artifact$get()`
- Cache artifacts locally: `artifact$cache()`
- Load artifacts into memory for a broad range of storage formats: `artifact$load()`
- Create artifacts from data frames, paths, and `AnnData` objects: `db$Artifact()`
- Delete records: `artifact$delete()`

See the development roadmap for more details (`vignette("development", package = "laminr")`).

## Installation

Get started with **{laminr}** by installing the package from CRAN:

```r
install.packages("laminr")
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
- **{rsvg}** - Reading SVG files

If you choose not to install all packages now you will be prompted to do so whenever one is required.

## Setting up

Before loading **{laminr}** for the first time you should:

1. Set up a Python environment

```r
laminr::install_lamindb()
```

2. Log in

```r
laminr::lamin_login(api_key = "your_api_key")
```

3. Set a default instance

```r
laminr::lamin_connect("<owner>/<name>")
```

See the [setup vignette](https://laminr.lamin.ai/articles/setup.html) for more information (`vignette("setup", package = "laminr")`).

## Getting started

The best way to get started with **{laminr}** is to explore the package vignettes (available at [laminr.lamin.ai](https://laminr.lamin.ai)):

- **Get started**: Learn the basics and explore practical examples (`vignette("laminr", package = "laminr")`).
- **Setting up laminr**: Learn the basics and explore practical examples (`vignette("setup", package = "laminr")`).
