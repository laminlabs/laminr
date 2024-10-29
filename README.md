# laminr: An R interface to LaminDB

<!-- badges: start -->
[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**laminr** is an R package that provides an interface to LaminDB, a powerful open-source data framework designed specifically for biological research. LaminDB enables you to manage, query, and track your data and metadata in a unified and scalable way.

## Features

laminr gives you access to the core functionalities of LaminDB, allowing you to:

* **Manage data and metadata**: Organize and access your data using LaminDB's Artifact and Record concepts.
* **Query and search**: Efficiently filter and search through your data and metadata.
* **Cache and load data**: Optimize data access with caching mechanisms.
* **Track data lineage**: Maintain a comprehensive history of your data transformations using Transform and Run.
* **Leverage ontologies**: Access and use public ontologies via bionty for standardized metadata.
* **Validate and standardize**: Ensure data quality with validation and standardization tools.
* And much more!

## Installation

Install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("laminlabs/laminr")
```

To install all suggested dependencies required for some functionality,
use:

``` r
remotes::install_github("laminlabs/laminr", dependencies = TRUE)
```

You will also need to install the `lamindb` Python package:

``` bash
pip install lamindb[aws]
```

## Documentation

* **Getting started** - Learn the basics of using laminr: `vignette("usage", package = "laminr")`

* **Core classes** - Get an overview of the core LaminDB classes in any Lamin instance: `vignette("core_classes", package = "laminr")`

* **Package architecture** - Understand the underlying structure of the package: `vignette("architecture", package = "laminr")`

* **Feature list and roadmap** - Explore the current features and future development plans: `vignette("development", package = "laminr")`

## Other resources

* [LaminDB website](https://lamin.ai/)

* [LaminDB documentation](https://docs.lamin.ai/)
