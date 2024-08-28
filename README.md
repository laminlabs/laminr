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

    <Instance>
      Public:
        initialize: function (instance_settings) 
      Private:
        cast_data_to_class: function (module_name, model_name, data) 
        classes: list
        create_classes: function () 
        generate_class: function (module_name, model_name) 
        get_record: function (module_name, model_name, id_or_uid, field_name = NULL) 
        instance_settings: InstanceSettings, R6
        schema: list

### Get artifact

``` r
# Planned:
# artifact <- db$artifact$get("KBW89Mf7IGcekja2hADu")

artifact <- db$.__enclos_env__$private$classes$core$artifact$get("KBW89Mf7IGcekja2hADu")
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
