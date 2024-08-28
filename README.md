# LaminDB interface in R


This package provides an interface to the LaminDB database. It allows
you to query the database and download data from it.

## Installation

You can install the development version from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("laminlabs/laminr")
```

<!--
## Set up environment
&#10;
For this package to work, we first need to run the following commands in the terminal:
&#10;```python
pip install lamindb
```
&#10;```bash
lamin load laminlabs/cellxgene
```
&#10;This should create an `.env` file at `~/.lamin/instance--laminlabs--cellxgene.env` and `~/.lamin/current_instance.env` containing an `instance_id`, `schema_id` and `api_url`, e.g.:
&#10;    # instance--laminlabs--cellxgene.env
    instance_id = "0123456789abcdefghijklmnopqrstuv"
    schema_id = "0123456789abcdefghijklmnopqrstuv"
    api_url = "https://us-west-2.api.lamin.ai"
&#10;:::{.callout-note}
laminr doesn't detect the `.env` yet, so you need to provide the `instance_id`, `schema_id` and `api_url` manually.
:::
&#10;-->

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(laminr)
```

### Connect to a LaminDB instance

``` r
options(
  lamindb_current_instance = list(
    owner = "lamin",
    name = "example",
    url = "https://us-west-2.api.lamin.ai",
    instance_id = "0123456789abcdefghijklmnopqrstuv",
    schema_id = "0123456789abcdefghijklmnopqrstuv"
  )
)

db <- laminr::connect()
```

### Print a LaminDB instance

``` r
db
```

    Instance 'lamin/cellxgene'
      core classes:
        Run
        User
        Param
        ULabel
        Feature
        Storage
        Artifact
        Transform
        Collection
        FeatureSet
        ParamValue
        FeatureValue
        RunParamValue
        ArtifactULabel
        CollectionULabel
        FeatureSetFeature
        ArtifactFeatureSet
        ArtifactParamValue
        CollectionArtifact
        ArtifactFeatureValue
        CollectionFeatureSet
      bionty classes:
        Gene
        Source
        Tissue
        Disease
        Pathway
        Protein
        CellLine
        CellType
        Organism
        Ethnicity
        Phenotype
        CellMarker
        ArtifactGene
        ArtifactTissue
        FeatureSetGene
        ArtifactDisease
        ArtifactPathway
        ArtifactProtein
        ArtifactCellLine
        ArtifactCellType
        ArtifactOrganism
        ArtifactEthnicity
        ArtifactPhenotype
        FeatureSetPathway
        FeatureSetProtein
        ArtifactCellMarker
        DevelopmentalStage
        ExperimentalFactor
        FeatureSetCellMarker
        ArtifactDevelopmentalStage
        ArtifactExperimentalFactor

<!--
### Print the Artifact class
&#10;
&#10;::: {.cell}
&#10;```{.r .cell-code}
db$Artifact
```
&#10;::: {.cell-output .cell-output-stdout}
&#10;```
<Artifact> object generator
  Inherits from: <Record>
  Public:
    initialize: function (data) 
    print: function (...) 
  Active bindings:
    id: function (value) 
    key: function (value) 
    run: function (value) 
    uid: function (value) 
    hash: function (value) 
    size: function (value) 
    type: function (value) 
    genes: function (value) 
    suffix: function (value) 
    storage: function (value) 
    tissues: function (value) 
    ulabels: function (value) 
    version: function (value) 
    _actions: function (value) 
    diseases: function (value) 
    pathways: function (value) 
    proteins: function (value) 
    _accessor: function (value) 
    is_latest: function (value) 
    n_objects: function (value) 
    organisms: function (value) 
    transform: function (value) 
    _hash_type: function (value) 
    _report_of: function (value) 
    cell_lines: function (value) 
    cell_types: function (value) 
    created_at: function (value) 
    created_by: function (value) 
    links_gene: function (value) 
    phenotypes: function (value) 
    updated_at: function (value) 
    visibility: function (value) 
    collections: function (value) 
    description: function (value) 
    ethnicities: function (value) 
    cell_markers: function (value) 
    feature_sets: function (value) 
    links_tissue: function (value) 
    links_ulabel: function (value) 
    _param_values: function (value) 
    input_of_runs: function (value) 
    links_disease: function (value) 
    links_pathway: function (value) 
    links_protein: function (value) 
    _previous_runs: function (value) 
    links_organism: function (value) 
    n_observations: function (value) 
    _action_targets: function (value) 
    _environment_of: function (value) 
    _feature_values: function (value) 
    _key_is_virtual: function (value) 
    _source_code_of: function (value) 
    links_cell_line: function (value) 
    links_cell_type: function (value) 
    links_ethnicity: function (value) 
    links_phenotype: function (value) 
    links_collection: function (value) 
    links_cell_marker: function (value) 
    links_feature_set: function (value) 
    _meta_of_collection: function (value) 
    _source_artifact_of: function (value) 
    _source_dataframe_of: function (value) 
    developmental_stages: function (value) 
    experimental_factors: function (value) 
    links_developmental_stage: function (value) 
    links_experimental_factor: function (value) 
  Parent env: <environment: 0x55692dfe5c90>
  Locked objects: TRUE
  Locked class: FALSE
  Portable: TRUE
```
&#10;
:::
:::
&#10;
&#10;-->

### Get artifact

``` r
artifact <- db$Artifact$get("KBW89Mf7IGcekja2hADu")
```

    Warning: Data is missing expected fields: run_id, storage_id, transform_id, created_by_id

### Print artifact

``` r
artifact
```

    Artifact(uid = 'KBW89Mf7IGcekja2hADu', key = 'cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad', description = 'Myeloid compartment', n_observations = '51552', hash = 'SZ5tB0T4YKfiUuUkAL09ZA', size = '691757462', is_latest = 'TRUE', _hash_type = 'md5-n', type = 'dataset', created_at = '2024-07-12T12:34:10.345829+00:00', updated_at = '2024-07-12T12:40:48.837026+00:00', _key_is_virtual = 'FALSE', visibility = '1', suffix = '.h5ad', version = '2024-07-01', _accessor = 'AnnData', id = '3659', n_objects = 'KBW89Mf7IGcekja2hADu')

### Print simple fields

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

### Print related fields

``` r
artifact$storage
```

    Warning: Data is missing expected fields: run_id, created_by_id

    Storage(id = '2', uid = 'oIYGbD74', root = 's3://cellxgene-data-public', type = 's3', region = 'us-west-2', created_at = '2023-09-19T13:17:56.273068+00:00', updated_at = '2023-10-16T15:04:08.998203+00:00', description = '2', instance_uid = 'oIYGbD74')

``` r
artifact$created_by
```

    User(id = '1', uid = 'kmvZDIX9', name = 'Sunny Sun', handle = 'sunnyosun', created_at = '2023-09-19T12:02:50.76501+00:00', updated_at = '2023-12-13T16:23:44.195541+00:00')

### Load artifact

> [!NOTE]
>
> This function will be moved to the `Artifact` class in the near
> future.

``` r
adata <- laminr:::artifact_load(artifact)
```

    Warning: Data is missing expected fields: run_id, created_by_id

``` r
# Planned usage:
# adata <- artifact$load()

adata
```

    AnnData object with n_obs × n_vars = 51552 × 36398
        obs: 'donor_id', 'Predicted_labels_CellTypist', 'Majority_voting_CellTypist', 'Manually_curated_celltype', 'assay_ontology_term_id', 'cell_type_ontology_term_id', 'development_stage_ontology_term_id', 'disease_ontology_term_id', 'self_reported_ethnicity_ontology_term_id', 'is_primary_data', 'organism_ontology_term_id', 'sex_ontology_term_id', 'tissue_ontology_term_id', 'suspension_type', 'tissue_type', 'cell_type', 'assay', 'disease', 'organism', 'sex', 'tissue', 'self_reported_ethnicity', 'development_stage', 'observation_joinid'
        var: 'gene_symbols', 'feature_is_filtered', 'feature_name', 'feature_reference', 'feature_biotype', 'feature_length'
        uns: 'cell_type_ontology_term_id_colors', 'citation', 'default_embedding', 'schema_reference', 'schema_version', 'sex_ontology_term_id_colors', 'title'
        obsm: 'X_umap'
