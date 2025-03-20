# {laminr}: An R client for LaminDB <a href="https://laminr.lamin.ai/"><img src="man/figures/logo.png" align="right" height="120" alt="laminr website" /></a>

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/laminr)](https://CRAN.R-project.org/package=laminr)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN checks](https://badges.cranchecks.info/summary/laminr.svg)](https://cran.r-project.org/web/checks/check_results_laminr.html)
[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**{laminr}** is an R client for [LaminDB](https://lamin.ai).
See the [documentation](https://laminr.lamin.ai/) for how to use **{laminr}**.

For more about LaminDB, please visit [https://docs.lamin.ai](https://docs.lamin.ai).

## Installation

Install the release version of **{laminr}** from CRAN:

```r
install.packages("laminr")
```

Or install the development version from GitHub:

```r
if (!requireNamespace("laminr", quietly = TRUE)) {
  install.packages("remotes")
}
remotes::install_github("laminlabs/laminr")
```

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
