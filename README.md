# LaminDB interface in R


<!-- badges: start -->

[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This package provides an interface to the LaminDB database. It allows
you to query the database and download data from it.

## Installation

You can install the development version from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("laminlabs/laminr")
```

## Set up environment

For this package to work, we first need to install `lamindb-setup` and
log in to LaminDB.

``` bash
pip install lamindb-setup
lamin login <your-email> --key <your-token>
```

> [!TIP]
>
> You can get your token from the [LaminDB web
> interface](https://lamin.ai/settings).

## Quick start

Let’s first connect to a LaminDB instance:

``` r
library(laminr)

db <- connect("laminlabs/cellxgene")
```

Get an artifact:

``` r
artifact <- db$Artifact$get("KBW89Mf7IGcekja2hADu")
```

Access some of its fields:

``` r
artifact$id
```

    [1] 3659

``` r
artifact$uid
```

    [1] "KBW89Mf7IGcekja2hADu"

``` r
artifact$key
```

    [1] "cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad"

Fetch related fields:

``` r
artifact$storage$root
```

    [1] "s3://cellxgene-data-public"

``` r
artifact$created_by$handle
```

    [1] "sunnyosun"

Load the artifact:

``` r
artifact$load()
```

    ℹ 's3://cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad' already exists at '/home/rcannood/.cache/lamindb/cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad'

    AnnData object with n_obs × n_vars = 51552 × 36398
        obs: 'donor_id', 'Predicted_labels_CellTypist', 'Majority_voting_CellTypist', 'Manually_curated_celltype', 'assay_ontology_term_id', 'cell_type_ontology_term_id', 'development_stage_ontology_term_id', 'disease_ontology_term_id', 'self_reported_ethnicity_ontology_term_id', 'is_primary_data', 'organism_ontology_term_id', 'sex_ontology_term_id', 'tissue_ontology_term_id', 'suspension_type', 'tissue_type', 'cell_type', 'assay', 'disease', 'organism', 'sex', 'tissue', 'self_reported_ethnicity', 'development_stage', 'observation_joinid'
        var: 'gene_symbols', 'feature_is_filtered', 'feature_name', 'feature_reference', 'feature_biotype', 'feature_length'
        uns: 'cell_type_ontology_term_id_colors', 'citation', 'default_embedding', 'schema_reference', 'schema_version', 'sex_ontology_term_id_colors', 'title'
        obsm: 'X_umap'
