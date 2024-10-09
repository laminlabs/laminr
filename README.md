# LaminR: Work with LaminDB instances in R


<!-- 
DO NOT edit the README.md directly.
&#10;Instead, edit the README.qmd file and render it using `quarto render README.qmd`. 
-->
<!-- badges: start -->

[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This package allows you to query and download data from LaminDB
instances.

## Setup

Install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("laminlabs/laminr")
```

Install the Lamin CLI and authenticate:

``` bash
pip install lamin-cli
lamin login
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
artifact
```

    Artifact(uid='KBW89Mf7IGcekja2hADu', description='Myeloid compartment', key='cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad', suffix='.h5ad', type='dataset', size=691757462, hash='SZ5tB0T4YKfiUuUkAL09ZA', n_observations=51552, visibility=1, version='2024-07-01', is_latest=TRUE, created_at='2024-07-12T12:34:10.345829+00:00', updated_at='2024-07-12T12:40:48.837026+00:00', created_by_id=1, storage_id=2, transform_id=22, run_id=27, _accessor='AnnData', _hash_type='md5-n', _key_is_virtual=FALSE, id=3659)

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

    ℹ 's3://cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad' already exists at '/home/luke/.cache/lamindb/cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad'

    AnnData object with n_obs × n_vars = 51552 × 36398
        obs: 'donor_id', 'Predicted_labels_CellTypist', 'Majority_voting_CellTypist', 'Manually_curated_celltype', 'assay_ontology_term_id', 'cell_type_ontology_term_id', 'development_stage_ontology_term_id', 'disease_ontology_term_id', 'self_reported_ethnicity_ontology_term_id', 'is_primary_data', 'organism_ontology_term_id', 'sex_ontology_term_id', 'tissue_ontology_term_id', 'suspension_type', 'tissue_type', 'cell_type', 'assay', 'disease', 'organism', 'sex', 'tissue', 'self_reported_ethnicity', 'development_stage', 'observation_joinid'
        var: 'gene_symbols', 'feature_is_filtered', 'feature_name', 'feature_reference', 'feature_biotype', 'feature_length'
        uns: 'cell_type_ontology_term_id_colors', 'citation', 'default_embedding', 'schema_reference', 'schema_version', 'sex_ontology_term_id_colors', 'title'
        obsm: 'X_umap'
