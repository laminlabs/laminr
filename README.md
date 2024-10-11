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

You will also need to install `lamindb`:

``` bash
pip install lamindb[bionty,wetlab]
```

## Connect to an instance

To connect to a LaminDB instance, you will first need to run
`lamin login` OR `lamin load <instance>` in the terminal. This will
create a directory in your home directory called `.lamin` with the
necessary credentials.

``` bash
lamin login
lamin connect laminlabs/cellxgene
```

Then, you can connect to the instance using the `laminr::connect()`
function:

``` r
library(laminr)

db <- connect("laminlabs/cellxgene")
db
```

    <cellxgene>
      Inherits from: <Instance>
      Public:
        Artifact: active binding
        bionty: active binding
        Collection: active binding
        Feature: active binding
        FeatureSet: active binding
        FeatureValue: active binding
        get_module: function (module_name) 
        get_module_names: function () 
        get_modules: function () 
        initialize: function (settings, api, schema) 
        Param: active binding
        ParamValue: active binding
        Run: active binding
        Storage: active binding
        Transform: active binding
        ULabel: active binding
        User: active binding
      Private:
        .api: API, R6
        .module_classes: list
        .settings: InstanceSettings, R6

## Query the instance

You can use the `db` object to query the instance:

``` r
artifact <- db$Artifact$get("KBW89Mf7IGcekja2hADu")
```

You can print the record:

``` r
artifact
```

    Artifact(uid='KBW89Mf7IGcekja2hADu', description='Myeloid compartment', key='cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad', storage_id=2, version='2024-07-01', _accessor='AnnData', id=3659, transform_id=22, n_observations=51552, created_by_id=1, size=691757462, _hash_type='md5-n', is_latest=TRUE, type='dataset', created_at='2024-07-12T12:34:10.345829+00:00', updated_at='2024-07-12T12:40:48.837026+00:00', _key_is_virtual=FALSE, visibility=1, run_id=27, suffix='.h5ad', hash='SZ5tB0T4YKfiUuUkAL09ZA')

Or call the `$describe()` method to get a summary:

``` r
artifact$describe()
```

    Artifact(uid='KBW89Mf7IGcekja2hADu', description='Myeloid compartment', key='cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad', storage_id=2, version='2024-07-01', _accessor='AnnData', id=3659, transform_id=22, n_observations=51552, created_by_id=1, size=691757462, _hash_type='md5-n', is_latest=TRUE, type='dataset', created_at='2024-07-12T12:34:10.345829+00:00', updated_at='2024-07-12T12:40:48.837026+00:00', _key_is_virtual=FALSE, visibility=1, run_id=27, suffix='.h5ad', hash='SZ5tB0T4YKfiUuUkAL09ZA')
      Provenance
        $storage = 's3://cellxgene-data-public'
        $transform = 'Census release 2024-07-01 (LTS)'
        $run = '2024-07-16T12:49:41.81955+00:00'
        $created_by = 'sunnyosun'

## Access fields

You can access its fields as follows:

- `artifact$id`: 3659
- `artifact$uid`: KBW89Mf7IGcekja2hADu
- `artifact$key`:
  cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad

You can also fetch related fields:

- `artifact$root`: s3://cellxgene-data-public
- `artifact$created_by`: sunnyosun

## Load the artifact

You can directly load the artifact to access its data:

``` r
artifact$load()
```

    ℹ 's3://cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad' already exists at '/home/rcannood/.cache/lamindb/cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad'

    AnnData object with n_obs × n_vars = 51552 × 36398
        obs: 'donor_id', 'Predicted_labels_CellTypist', 'Majority_voting_CellTypist', 'Manually_curated_celltype', 'assay_ontology_term_id', 'cell_type_ontology_term_id', 'development_stage_ontology_term_id', 'disease_ontology_term_id', 'self_reported_ethnicity_ontology_term_id', 'is_primary_data', 'organism_ontology_term_id', 'sex_ontology_term_id', 'tissue_ontology_term_id', 'suspension_type', 'tissue_type', 'cell_type', 'assay', 'disease', 'organism', 'sex', 'tissue', 'self_reported_ethnicity', 'development_stage', 'observation_joinid'
        var: 'gene_symbols', 'feature_is_filtered', 'feature_name', 'feature_reference', 'feature_biotype', 'feature_length'
        uns: 'cell_type_ontology_term_id_colors', 'citation', 'default_embedding', 'schema_reference', 'schema_version', 'sex_ontology_term_id_colors', 'title'
        obsm: 'X_umap'
