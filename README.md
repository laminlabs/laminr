# {laminr}: An R interface to LaminDB

<!-- badges: start -->

[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

**{laminr}** is an R package that provides an interface to [LaminDB](https://lamin.ai).

> [!WARNING]  
> This package is currently in **early access** and is under active development.
> Features, APIs, and functionality are subject to change.

## What is LaminDB

If you are new to LaminDB, it's helpful to start with [Lamin's problem statement](https://lamin.ai/blog/problems).
LaminDB is an open-source data framework for biology, built as a Python API that structures data and metadata, tracks analysis lineage, and enables reproducible, scalable research.
With tools for curating data against public ontologies and flexible dataset querying, LaminDB is designed to address core data challenges in the field.
Please refer to [LaminDB's introduction](https://docs.lamin.ai/introduction) for a more detailed introduction.
LaminDB is accompanied by LaminHub which is a data collaboration hub built on LaminDB similar to how Github is built on git.

## Features of **{laminr}**

- Connect to a LaminDB instance and list all records in a registry.
- Fetch records by ID or UID.
- Cache S3 artifacts locally.
- Load AnnData artifacts natively in R.

See the development roadmap for more details (`vignette("development", package = "laminr")`).

## Installation

Get started with **{laminr}** by installing the development version directly from GitHub:

```r
# install.packages("remotes")
remotes::install_github("laminlabs/laminr")
```

To include all suggested dependencies for enhanced functionality, use:

```r
remotes::install_github("laminlabs/laminr", dependencies = TRUE)
```

This further installs:

- anndata: For native AnnData support in R
- S3: To fetch datasets from AWS S3

For now, you will also need to install the `lamindb` Python package:

```bash
pip install lamindb[aws]
```

## Getting started

The best way to get started with **{laminr}** is to explore the package vignettes (available at [laminr.lamin.ai](https://laminr.lamin.ai)):

- **Getting Started**: Learn the basics and explore practical examples (`vignette("laminr", package = "laminr")`).
- **Package Architecture**: Get a better understanding of how **{laminr}** works (`vignette("architecture", package = "laminr")`).

For information on specific modules and functionalities, check out the following vignettes:

- **Core Module**: Learn about the core registries available in a LaminDB instance (`vignette("module_core", package = "laminr")`).
- **Bionty Module**: Explore the bionty module for biology-related entities (`vignette("module_bionty", package = "laminr")`).

## Learn more

For more information about LaminDB and its features, check out the following resources:

- [LaminDB website](https://lamin.ai/)
- [LaminDB documentation](https://docs.lamin.ai/)
