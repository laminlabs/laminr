# LaminR: Work with LaminDB instances in R

<!-- badges: start -->

[![R-CMD-check](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/laminlabs/laminr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This package allows you to query & download data from LaminDB instances.

## Setup

Install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("laminlabs/laminr")
```

Install the Lamin CLI & authenticate:

``` bash
pip install lamin-cli
lamin login
```

## Usage

``` r
library(laminr)
```

### Datbaase instance

``` r
db <- connect("laminlabs/cellxgene")
```

``` r
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

### Schema module

``` r
db$get_module("core")
```

    <core>
      Inherits from: <Module>
      Public:
        Artifact: active binding
        Collection: active binding
        Feature: active binding
        FeatureSet: active binding
        FeatureValue: active binding
        get_registries: function () 
        get_registry: function (registry_name) 
        get_registry_names: function () 
        initialize: function (instance, api, module_name, module_schema) 
        name: active binding
        Param: active binding
        ParamValue: active binding
        Run: active binding
        Storage: active binding
        Transform: active binding
        ULabel: active binding
        User: active binding
      Private:
        .api: API, R6
        .instance: cellxgene, Instance, R6
        .module_name: core
        .registry_classes: list

``` r
db$bionty
```

    <bionty>
      Inherits from: <Module>
      Public:
        CellLine: active binding
        CellMarker: active binding
        CellType: active binding
        DevelopmentalStage: active binding
        Disease: active binding
        Ethnicity: active binding
        ExperimentalFactor: active binding
        Gene: active binding
        get_registries: function () 
        get_registry: function (registry_name) 
        get_registry_names: function () 
        initialize: function (instance, api, module_name, module_schema) 
        name: active binding
        Organism: active binding
        Pathway: active binding
        Phenotype: active binding
        Protein: active binding
        Source: active binding
        Tissue: active binding
      Private:
        .api: API, R6
        .instance: cellxgene, Instance, R6
        .module_name: bionty
        .registry_classes: list

### Registry

``` r
db$Artifact
```

    <Registry>
      Public:
        class_name: active binding
        get: function (id_or_uid, include_foreign_keys = TRUE, verbose = FALSE) 
        get_field: function (field_name) 
        get_field_names: function () 
        get_fields: function () 
        get_record_class: function () 
        initialize: function (instance, module, api, registry_name, registry_schema) 
        is_link_table: active binding
        module: active binding
        name: active binding
      Private:
        .api: API, R6
        .class_name: Artifact
        .fields: list
        .instance: cellxgene, Instance, R6
        .is_link_table: FALSE
        .module: core, Module, R6
        .record_class: R6ClassGenerator
        .registry_name: artifact

``` r
db$bionty$CellLine
```

    <Registry>
      Public:
        class_name: active binding
        get: function (id_or_uid, include_foreign_keys = TRUE, verbose = FALSE) 
        get_field: function (field_name) 
        get_field_names: function () 
        get_fields: function () 
        get_record_class: function () 
        initialize: function (instance, module, api, registry_name, registry_schema) 
        is_link_table: active binding
        module: active binding
        name: active binding
      Private:
        .api: API, R6
        .class_name: CellLine
        .fields: list
        .instance: cellxgene, Instance, R6
        .is_link_table: FALSE
        .module: bionty, Module, R6
        .record_class: R6ClassGenerator
        .registry_name: cellline

## Record

### Get artifact

``` r
artifact <- db$Artifact$get("KBW89Mf7IGcekja2hADu")
```

### Print artifact

``` r
artifact
```

    <Artifact>
      Inherits from: <ArtifactRecord>
      Public:
        _accessor: active binding
        _action_targets: active binding
        _actions: active binding
        _environment_of: active binding
        _feature_values: active binding
        _hash_type: active binding
        _key_is_virtual: active binding
        _meta_of_collection: active binding
        _param_values: active binding
        _previous_runs: active binding
        _report_of: active binding
        _source_artifact_of: active binding
        _source_code_of: active binding
        _source_dataframe_of: active binding
        cache: function () 
        cell_lines: active binding
        cell_markers: active binding
        cell_types: active binding
        clone: function (deep = FALSE) 
        collections: active binding
        created_at: active binding
        created_by: active binding
        description: active binding
        developmental_stages: active binding
        diseases: active binding
        ethnicities: active binding
        experimental_factors: active binding
        feature_sets: active binding
        genes: active binding
        hash: active binding
        id: active binding
        initialize: function (data) 
        input_of_runs: active binding
        is_latest: active binding
        key: active binding
        links_cell_line: active binding
        links_cell_marker: active binding
        links_cell_type: active binding
        links_collection: active binding
        links_developmental_stage: active binding
        links_disease: active binding
        links_ethnicity: active binding
        links_experimental_factor: active binding
        links_feature_set: active binding
        links_gene: active binding
        links_organism: active binding
        links_pathway: active binding
        links_phenotype: active binding
        links_protein: active binding
        links_tissue: active binding
        links_ulabel: active binding
        load: function () 
        n_objects: active binding
        n_observations: active binding
        organisms: active binding
        pathways: active binding
        phenotypes: active binding
        proteins: active binding
        run: active binding
        size: active binding
        storage: active binding
        suffix: active binding
        tissues: active binding
        transform: active binding
        type: active binding
        uid: active binding
        ulabels: active binding
        updated_at: active binding
        version: active binding
        visibility: active binding
      Private:
        .api: API, R6
        .data: list
        .instance: cellxgene, Instance, R6
        .registry: Registry, R6
        get_value: function (key) 

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

    <Storage>
      Inherits from: <Record>
      Public:
        _previous_runs: active binding
        artifacts: active binding
        created_at: active binding
        created_by: active binding
        description: active binding
        id: active binding
        initialize: function (data) 
        instance_uid: active binding
        region: active binding
        root: active binding
        run: active binding
        type: active binding
        uid: active binding
        updated_at: active binding
      Private:
        .api: API, R6
        .data: list
        .instance: cellxgene, Instance, R6
        .registry: Registry, R6
        get_value: function (key) 

``` r
artifact$created_by
```

    <User>
      Inherits from: <Record>
      Public:
        created_artifacts: active binding
        created_at: active binding
        created_runs: active binding
        created_transforms: active binding
        handle: active binding
        id: active binding
        initialize: function (data) 
        name: active binding
        uid: active binding
        updated_at: active binding
      Private:
        .api: API, R6
        .data: list
        .instance: cellxgene, Instance, R6
        .registry: Registry, R6
        get_value: function (key) 

``` r
artifact$experimental_factors
```

    Warning: Data is missing expected fields: run_id, source_id, created_by_id

    Warning: Data is missing expected fields: run_id, source_id, created_by_id
    Data is missing expected fields: run_id, source_id, created_by_id

    [[1]]
    <ExperimentalFactor>
      Inherits from: <Record>
      Public:
        _previous_runs: active binding
        abbr: active binding
        artifacts: active binding
        children: active binding
        created_at: active binding
        created_by: active binding
        description: active binding
        id: active binding
        initialize: function (data) 
        instrument: active binding
        links_artifact: active binding
        measurement: active binding
        molecule: active binding
        name: active binding
        ontology_id: active binding
        parents: active binding
        run: active binding
        source: active binding
        synonyms: active binding
        uid: active binding
        updated_at: active binding
      Private:
        .api: API, R6
        .data: list
        .instance: cellxgene, Instance, R6
        .registry: Registry, R6
        get_value: function (key) 

    [[2]]
    <ExperimentalFactor>
      Inherits from: <Record>
      Public:
        _previous_runs: active binding
        abbr: active binding
        artifacts: active binding
        children: active binding
        created_at: active binding
        created_by: active binding
        description: active binding
        id: active binding
        initialize: function (data) 
        instrument: active binding
        links_artifact: active binding
        measurement: active binding
        molecule: active binding
        name: active binding
        ontology_id: active binding
        parents: active binding
        run: active binding
        source: active binding
        synonyms: active binding
        uid: active binding
        updated_at: active binding
      Private:
        .api: API, R6
        .data: list
        .instance: cellxgene, Instance, R6
        .registry: Registry, R6
        get_value: function (key) 

    [[3]]
    <ExperimentalFactor>
      Inherits from: <Record>
      Public:
        _previous_runs: active binding
        abbr: active binding
        artifacts: active binding
        children: active binding
        created_at: active binding
        created_by: active binding
        description: active binding
        id: active binding
        initialize: function (data) 
        instrument: active binding
        links_artifact: active binding
        measurement: active binding
        molecule: active binding
        name: active binding
        ontology_id: active binding
        parents: active binding
        run: active binding
        source: active binding
        synonyms: active binding
        uid: active binding
        updated_at: active binding
      Private:
        .api: API, R6
        .data: list
        .instance: cellxgene, Instance, R6
        .registry: Registry, R6
        get_value: function (key) 

### Download & cache an artifact

> [!NOTE]
>
> Only S3 storage is supported at the moment.

``` r
artifact$cache()
```

    Warning: Data is missing expected fields: run_id, created_by_id

    ℹ 's3://cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad' already exists at '/home/rcannood/.cache/lamindb/cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad'

### Load an artifact

> [!NOTE]
>
> Only S3 storage and AnnData accessors are supported at the moment.

``` r
artifact$load()
```

    Warning: Data is missing expected fields: run_id, created_by_id

    ℹ 's3://cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad' already exists at '/home/rcannood/.cache/lamindb/cellxgene-data-public/cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad'

    AnnData object with n_obs × n_vars = 51552 × 36398
        obs: 'donor_id', 'Predicted_labels_CellTypist', 'Majority_voting_CellTypist', 'Manually_curated_celltype', 'assay_ontology_term_id', 'cell_type_ontology_term_id', 'development_stage_ontology_term_id', 'disease_ontology_term_id', 'self_reported_ethnicity_ontology_term_id', 'is_primary_data', 'organism_ontology_term_id', 'sex_ontology_term_id', 'tissue_ontology_term_id', 'suspension_type', 'tissue_type', 'cell_type', 'assay', 'disease', 'organism', 'sex', 'tissue', 'self_reported_ethnicity', 'development_stage', 'observation_joinid'
        var: 'gene_symbols', 'feature_is_filtered', 'feature_name', 'feature_reference', 'feature_biotype', 'feature_length'
        uns: 'cell_type_ontology_term_id_colors', 'citation', 'default_embedding', 'schema_reference', 'schema_version', 'sex_ontology_term_id_colors', 'title'
        obsm: 'X_umap'
