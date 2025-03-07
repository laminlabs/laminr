# {laminr}: An R client for LaminDB

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/laminr)](https://CRAN.R-project.org/package=laminr)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**{laminr}** is an R client for [LaminDB](https://lamin.ai).
If you are new to LaminDB, please read this [introduction](https://docs.lamin.ai/guide).

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

See the [setup vignette](https://laminr.lamin.ai/articles/setup.html) for more information.

## Getting started

The best way to get started with **{laminr}** is to explore the package vignettes (available at [laminr.lamin.ai](https://laminr.lamin.ai)):

- [**Get started**](https://laminr.lamin.ai/articles/laminr.html): Learn the basics and explore practical examples
- [**Setting up laminr**](https://laminr.lamin.ai/articles/setup.html): Learn set up **{laminr}** and manage Python environments
- [**Introduction to LaminDB**](https://laminr.lamin.ai/articles/introduction.html): Code for reproducing the LaminDB introduction guide
