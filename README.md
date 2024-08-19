# LaminDB interface in R


This package provides an interface to the LaminDB database. It allows
you to query the database and download data from it.

## Installation

You can install the development version from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("laminlabs/laminr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(laminr)

ln <- LaminDB$new(
  url = "https://us-west-2.api.lamin.ai",
  instance_id = "399387d4-feec-45b5-995d-5b5750f5542c",
  schema_id = "a122335a-0d85-cf36-291d-9e98a6dd1417"
)
```

Fetch artifact:

``` r
artifact <- ln$types$core$artifact$get_record(
  id_or_uid = "KBW89Mf7IGcekja2hADu"
)
```

    Fetching record for core.artifact with id_or_uid: KBW89Mf7IGcekja2hADu

    Warning in ln$types$core$artifact$get_record(id_or_uid = "KBW89Mf7IGcekja2hADu"): Unexpected fields found in data: is_latest

> [!NOTE]
>
> The data returned by the API contains a field `is_latest`. Since it is
> not present in the schema, it is current ignored by the package.

``` r
artifact
```

    Artifact:
      version: 2024-07-01
      created_at: 2024-07-12T12:34:10.345829+00:00
      updated_at: 2024-07-12T12:40:48.837026+00:00
      id: 3659
      uid: KBW89Mf7IGcekja2hADu
      description: Myeloid compartment
      key: cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad
      suffix: .h5ad
      type: dataset
      _accessor: AnnData
      size: 691757462
      hash: SZ5tB0T4YKfiUuUkAL09ZA
      _hash_type: md5-n
      n_objects: 
      n_observations: 51552
      visibility: 1
      _key_is_virtual: FALSE
      created_by_id: 1
      storage_id: 2
      transform_id: 22
      run_id: 27

``` r
artifact$id
```

    [1] 3659

``` r
artifact$storage_id
```

    [1] 2

``` r
artifact$visibility
```

    [1] 1

## Issue: Can’t fetch records with id, only with uid

Unfortunately, the following code does not work:

``` r
artifact$storage()
```

This is because calling `storage()` actually calls `get_record` with the
`artifact$storage_id` as argument:

``` r
ln$types$core$storage$get_record(
  id_or_uid = artifact$storage_id
)
```

However, it seems `get_record` only works with `uid` and not with `id`.

<!--
### `fields_metadata` contains entries for other models
&#10;...
&#10;### `fields_metadata` contains duplicate entries
&#10;core.run contains duplicate field 'id'
&#10;```r
fields <- 
  ln$.__enclos_env__$private$schemas[["core"]][["run"]] %>%
  .$fields_metadata %>%
  unname() %>%
  dynutils::list_as_tibble() %>%
  filter(model_name == "run") %>%
  filter(!is.na(column))
&#10;fields %>% filter(column == "id")
```
-->
