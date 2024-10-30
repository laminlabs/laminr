# {laminr}: An R interface to LaminDB

<!-- badges: start -->
[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**{laminr}** is an R package that provides an interface to [LaminDB](https://lamin.ai), a powerful open-source data framework designed specifically for biological research. With laminr, you can leverage LaminDB's powerful features to manage, query, and track your data and metadata with unparalleled efficiency and scalability, all within the familiar comfort of R.

## Why use {laminr}?

LaminDB offers a unique approach to data management in bioinformatics, providing:

* **Unified Data and Metadata Handling**: Organize your data and its associated metadata in a structured and accessible manner.
* **Powerful Querying and Search**: Effortlessly filter and retrieve specific data and metadata using intuitive query functions.
* **Data Lineage Tracking**: Maintain a comprehensive history of your data transformations, ensuring reproducibility and transparency.
* **Ontology Integration**: Leverage public ontologies (e.g., for genes, proteins, cell types) for standardized metadata annotation.
* **Data Validation and Standardization**: Ensure data quality and consistency with built-in validation and standardization tools.

**{laminr}** brings all these benefits to your R workflow, allowing you to seamlessly integrate LaminDB into your existing analysis pipelines.

## Installation

Get started with **{laminr}** by installing the development version directly from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("laminlabs/laminr")
```

To include all suggested dependencies for enhanced functionality, use:

``` r
remotes::install_github("laminlabs/laminr", dependencies = TRUE)
```

You will also need to install the `lamindb` Python package:

``` bash
pip install lamindb[aws]
```

## Getting started

The best way to get started with **{laminr}** is to explore the package vignettes:

* **Getting Started**: Learn the basics and explore practical examples (`vignette("laminr", package = "laminr")`).
* **Package Architecture**: Get a better understanding of how **{laminr}** works (`vignette("architecture", package = "laminr")`).
* **Development Roadmap**: Explore current features and future development plans (`vignette("development", package = "laminr")`).

For information on specific modules and functionalities, check out the following vignettes:

* **Core Module**: Learn about the core registries available in a LaminDB instance (`vignette("module_core", package = "laminr")`).
* **Bionty Module**: Explore the bionty module for biology-related entities (`vignette("module_bionty", package = "laminr")`).
    
## Learn more

For more information about LaminDB and its features, check out the following resources:

* [LaminDB website](https://lamin.ai/)

* [LaminDB documentation](https://docs.lamin.ai/)
