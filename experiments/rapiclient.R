# install.packages("rapiclient")

library(rapiclient)
library(httr)
library(tidyverse)

lamin_api <- get_api(url = "https://us-west-2.api.lamin.ai/openapi.json")
operations <- get_operations(lamin_api)
schemas <- get_schemas(lamin_api)

# this info needs to be fetched from an .env file somewhere
instance_id <- "399387d4-feec-45b5-995d-5b5750f5542c"
schema_id <- "a122335a-0d85-cf36-291d-9e98a6dd1417"

# get schema
schema <- operations$get_schema_instances__instance_id__schema__get(instance_id = instance_id) |>
  content()

schema$core$artifact$class_name # "Artifact"

artifact_fields <- schema$core$artifact$fields_metadata %>%
  unname() %>%
  dynutils::list_as_tibble() %>%
  filter(model_name == "artifact")
# # A tibble: 67 × 11
#    schema_name related_schema_name model_name related_model_name field_name  related_field_name column      type          relation_type is_link_table .object_class
#    <chr>       <chr>               <chr>      <chr>              <chr>       <chr>              <chr>       <chr>         <chr>         <lgl>         <list>       
#  1 core        NA                  artifact   NA                 version     NA                 version     CharField     NA            FALSE         <chr [1]>    
#  2 core        NA                  artifact   NA                 created_at  NA                 created_at  DateTimeField NA            FALSE         <chr [1]>    
#  3 core        NA                  artifact   NA                 updated_at  NA                 updated_at  DateTimeField NA            FALSE         <chr [1]>    
#  4 core        NA                  artifact   NA                 id          NA                 id          AutoField     NA            FALSE         <chr [1]>    
#  5 core        NA                  artifact   NA                 uid         NA                 uid         CharField     NA            FALSE         <chr [1]>    
#  6 core        NA                  artifact   NA                 description NA                 description CharField     NA            FALSE         <chr [1]>    
#  7 core        NA                  artifact   NA                 key         NA                 key         CharField     NA            FALSE         <chr [1]>    
#  8 core        NA                  artifact   NA                 suffix      NA                 suffix      CharField     NA            FALSE         <chr [1]>    
#  9 core        NA                  artifact   NA                 type        NA                 type        CharField     NA            FALSE         <chr [1]>    
# 10 core        NA                  artifact   NA                 _accessor   NA                 _accessor   CharField     NA            FALSE         <chr [1]>   

artifact_record <- operations$get_record_instances__instance_id__modules__module_name___model_name___id_or_uid__post(
  instance_id = instance_id,
  module_name = "core",
  model_name = "artifact",
  id_or_uid = artifact_uid,
  schema_id = schema_id
) |> content()

artifact_record

# $id
# [1] 1443

# $key
# [1] "cell-census/2023-07-25/h5ads/add5eb84-5fc9-4f01-982e-a346dd42ee82.h5ad"

# $run_id
# [1] 16

# $uid
# [1] "jWM5kRgHf8S4kID1o9jU"

# $hash
# [1] "c5kOrx1G6BNuA15yoezcAQ"

# $size
# [1] 3874975

# $type
# NULL

# $suffix
# [1] ".h5ad"

# $storage_id
# [1] 2

# $version
# [1] "2023-07-25"

# $`_accessor`
# [1] "AnnData"

# $is_latest
# [1] FALSE

# $n_objects
# NULL

# $transform_id
# [1] 11

# $`_hash_type`
# [1] "md5"

# $created_at
# [1] "2023-11-28T21:46:23.123163+00:00"

# $created_by_id
# [1] 1

# $updated_at
# [1] "2024-01-24T07:13:02.149345+00:00"

# $visibility
# [1] 1

# $description
# [1] "Spatial transcriptomics in mouse: Puck_191109_20"

# $n_observations
# [1] 12906

# $`_key_is_virtual`
# [1] FALSE

records <- operations$get_records_instances__instance_id__modules__module_name___model_name__post(
  instance_id = instance_id,
  module_name = "core",
  model_name = "artifact",
  schema_id = schema_id
) |>
  content() |>
  dynutils::list_as_tibble()

# # A tibble: 50 × 23
#       id key      run_id uid   hash    size type  suffix storage_id version `_accessor` is_latest n_objects transform_id `_hash_type` created_at created_by_id updated_at visibility
#    <int> <chr>     <int> <chr> <chr>  <dbl> <lgl> <chr>       <int> <chr>   <chr>       <lgl>     <lgl>            <int> <chr>        <chr>              <int> <chr>           <int>
#  1  1270 cell-ce…     16 tczT… UlsV… 1.30e9 NA    .h5ad           2 2023-0… AnnData     FALSE     NA                  11 md5-n        2023-11-2…             1 2024-01-2…          1
#  2  2840 NA           NA JIIP… gNdU… 3.63e4 NA    .ipynb          3 0       NA          FALSE     NA                  NA md5          2024-01-2…             1 2024-01-2…          0
#  3  2842 NA           NA Whyx… BDGZ… 7.17e5 NA    .html           3 1       NA          FALSE     NA                  NA md5          2024-01-2…             1 2024-01-3…          0
#  4  1398 cell-ce…     16 aOPF… rLPN… 3.18e7 NA    .h5ad           2 2023-0… AnnData     FALSE     NA                  11 md5-n        2023-11-2…             1 2024-01-2…          1
#  5   875 cell-ce…     16 bitt… PxGg… 5.92e6 NA    .h5ad           2 2023-0… AnnData     FALSE     NA                  11 md5          2023-11-2…             1 2024-01-2…          1
#  6  1363 cell-ce…     16 Urf0… wqeL… 3.74e7 NA    .h5ad           2 2023-0… AnnData     FALSE     NA                  11 md5-n        2023-11-2…             1 2024-01-2…          1
#  7  1006 cell-ce…     16 AtL7… rUkH… 2.83e8 NA    .h5ad           2 2023-0… AnnData     FALSE     NA                  11 md5-n        2023-11-2…             1 2024-01-2…          1
#  8  1717 cell-ce…     16 6GM0… PFgO… 2.20e7 NA    .h5ad           2 2023-0… AnnData     FALSE     NA                  11 md5-n        2023-11-2…             1 2024-01-2…          1
#  9  1613 cell-ce…     16 qnlB… -2OE… 3.97e7 NA    .h5ad           2 2023-0… AnnData     FALSE     NA                  11 md5-n        2023-11-2…             1 2024-01-2…          1
# 10  1497 cell-ce…     16 w6UN… oaxW… 3.43e7 NA    .h5ad           2 2023-0… AnnData     FALSE     NA                  11 md5-n        2023-11-2…             1 2024-01-2…          1
# # ℹ 40 more rows
# # ℹ 4 more variables: description <chr>, n_observations <int>, `_key_is_virtual` <lgl>, .object_class <list>
# # ℹ Use `print(n = ...)` to see more rows