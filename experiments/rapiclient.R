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
schemas <- operations$get_schema_instances__instance_id__schema__get(instance_id = instance_id) |>
  content()

schemas$core$artifact$class_name # "Artifact"

artifact_fields <- schemas$core$artifact$fields_metadata %>%
  unname() %>%
  dynutils::list_as_tibble() %>%
  filter(model_name == "artifact")

module_name <- "core"; model_name <- "artifact"
generate_r6 <- function(module_name, model_name) {
  class_name <- schemas[[module_name]][[model_name]]$class_name

  fields <- schemas[[module_name]][[model_name]]$fields_metadata %>%
    unname() %>%
    dynutils::list_as_tibble() %>%
    filter(model_name == !!model_name) %>%
    filter(!is.na(column))

  related_fields <- fields %>%
    filter(!is.na(relation_type))

  # generate initialize function
  initialize_fun_src <- paste0(
    "initialize_fun <- function(",
    paste(paste0("`", fields$column, "`"), collapse = ", "),
    ") {\n",
    paste(
      paste0("  self$`", fields$column, "` <- `", fields$column, "`"),
      collapse = "\n"
    ),
    "\n}\n"
  )
  eval(parse(text = initialize_fun_src))

  # generate initial values
  public_fields <- setNames(lapply(fields$column, function(x) NULL), fields$column)
  
  # generate relation lookup functions
  lookup_funs <- setNames(
    pmap(related_fields, function(related_schema_name, related_model_name, column, ...) {
      lookup_fun_src <- paste0(
        "lookup <- function() {\n",
        "  fetch_data(\n",
        "    module_name = '", related_schema_name, "',\n",
        "    model_name = '", related_model_name, "',\n",
        "    id_or_uid = self$`", column, "`\n",
        "  )\n",
        "}\n"
      )
      eval(parse(text = lookup_fun_src))
      lookup
    }),
    related_fields$field_name
  )

  R6::R6Class(
    class_name,
    public = c(
      list(initialize = initialize_fun),
      public_fields,
      lookup_funs
    ),
    cloneable = FALSE
  )
}

r6_classes <- lapply(
  names(schemas),
  function(module_name) {
    out <- lapply(
      names(schemas[[module_name]]),
      function(model_name) {
        tryCatch({
          generate_r6(module_name = module_name, model_name = model_name)
        }, error = function(e) {
          cat("Error generating R6 class for ", module_name, ":", model_name, "\n", sep = "")
          cat(e$message, "\n")
        })
      }
    )
    setNames(out, names(schemas[[module_name]]))
  }
)
names(r6_classes) <- names(schemas)
Artifact <- generate_r6("core", "artifact")

obj_fields <- artifact_fields %>%
  filter(!is.na(column)) %>%
  select(-schema_name:-related_schema_name, -relation_type:-.object_class)
obj_fields %>%
  print(n = 100)
# A tibble: 21 × 6
#    model_name related_model_name field_name      related_field_name column          type             
#    <chr>      <chr>              <chr>           <chr>              <chr>           <chr>            
#  1 artifact   NA                 version         NA                 version         CharField        
#  2 artifact   NA                 created_at      NA                 created_at      DateTimeField    
#  3 artifact   NA                 updated_at      NA                 updated_at      DateTimeField    
#  4 artifact   NA                 id              NA                 id              AutoField        
#  5 artifact   NA                 uid             NA                 uid             CharField        
#  6 artifact   NA                 description     NA                 description     CharField        
#  7 artifact   NA                 key             NA                 key             CharField        
#  8 artifact   NA                 suffix          NA                 suffix          CharField        
#  9 artifact   NA                 type            NA                 type            CharField        
# 10 artifact   NA                 _accessor       NA                 _accessor       CharField        
# 11 artifact   NA                 size            NA                 size            BigIntegerField  
# 12 artifact   NA                 hash            NA                 hash            CharField        
# 13 artifact   NA                 _hash_type      NA                 _hash_type      CharField        
# 14 artifact   NA                 n_objects       NA                 n_objects       BigIntegerField  
# 15 artifact   NA                 n_observations  NA                 n_observations  BigIntegerField  
# 16 artifact   NA                 visibility      NA                 visibility      SmallIntegerField
# 17 artifact   NA                 _key_is_virtual NA                 _key_is_virtual BooleanField     
# 18 artifact   user               created_by      artifact           created_by_id   ForeignKey       
# 19 artifact   storage            storage         artifacts          storage_id      ForeignKey       
# 20 artifact   transform          transform       output_artifacts   transform_id    ForeignKey       
# 21 artifact   run                run             output_artifacts   run_id          ForeignKey



fetch_data <- function(module_name, model_name, id_or_uid) {
  cat("fetching data for ", module_name, ":", model_name, "with id or uid '", id_or_uid, "'\n", sep = "")
  data <- operations$get_record_instances__instance_id__modules__module_name___model_name___id_or_uid__post(
    instance_id = instance_id,
    schema_id = schema_id,
    module_name = module_name,
    model_name = model_name,
    id_or_uid = id_or_uid
  ) |> content()
  class <- r6_classes[[module_name]][[model_name]]
  obj <- do.call(class$new, data[intersect(names(data), names(class$public_fields))])
  obj
}

# get info on one record
artifact <- operations$get_record_instances__instance_id__modules__module_name___model_name___id_or_uid__post(
  instance_id = instance_id,
  schema_id = schema_id,
  module_name = "core",
  model_name = "artifact",
  id_or_uid = "KBW89Mf7IGcekja2hADu",
) |> content()

artifact

art_obj <- do.call(Artifact$new, artifact[intersect(names(artifact), names(Artifact$public_fields))])
art_obj

artifact_obj <- fetch_data("core", "artifact", "KBW89Mf7IGcekja2hADu")

artifact_obj

# <Artifact>
#   Public:
#     _accessor: AnnData
#     _hash_type: md5-n
#     _key_is_virtual: FALSE
#     created_at: 2024-07-12T12:34:10.345829+00:00
#     created_by: function () 
#     created_by_id: 1
#     description: Myeloid compartment
#     hash: SZ5tB0T4YKfiUuUkAL09ZA
#     id: 3659
#     initialize: function (version, created_at, updated_at, id, uid, description, 
#     key: cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb ...
#     n_objects: NULL
#     n_observations: 51552
#     run: function () 
#     run_id: 27
#     size: 691757462
#     storage: function () 
#     storage_id: 2
#     suffix: .h5ad
#     transform: function () 
#     transform_id: 22
#     type: dataset
#     uid: KBW89Mf7IGcekja2hADu
#     updated_at: 2024-07-12T12:40:48.837026+00:00
#     version: 2024-07-01
#     visibility: 1

artifact_obj$storage()
artifact_obj$transform()
artifact_obj$run()

art_obj$storage()

# $id
# [1] 3659

# $key
# [1] "cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad"

# $run_id
# [1] 27

# $uid
# [1] "KBW89Mf7IGcekja2hADu"

# $hash
# [1] "SZ5tB0T4YKfiUuUkAL09ZA"

# $size
# [1] 691757462

# $type
# [1] "dataset"

# $suffix
# [1] ".h5ad"

# $storage_id
# [1] 2

# $version
# [1] "2024-07-01"

# $`_accessor`
# [1] "AnnData"

# $is_latest
# [1] TRUE

# $n_objects
# NULL

# $transform_id
# [1] 22

# $`_hash_type`
# [1] "md5-n"

# $created_at
# [1] "2024-07-12T12:34:10.345829+00:00"

# $created_by_id
# [1] 1

# $updated_at
# [1] "2024-07-12T12:40:48.837026+00:00"

# $visibility
# [1] 1

# $description
# [1] "Myeloid compartment"

# $n_observations
# [1] 51552

# $`_key_is_virtual`
# [1] FALSE

artifact_records <- operations$get_records_instances__instance_id__modules__module_name___model_name__post(
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

artifact_storage <- operations$get_record_instances__instance_id__modules__module_name___model_name___id_or_uid__post(
  instance_id = instance_id,
  schema_id = schema_id,
  module_name = "core",
  model_name = "storage",
  id_or_uid = artifact$storage_id
) |> content()

storage <- operations$get_records_instances__instance_id__modules__module_name___model_name__post(
  instance_id = instance_id,
  module_name = "core",
  model_name = "storage",
  schema_id = schema_id
) |>
  content() |>
  dynutils::list_as_tibble()


# download h5ad
artifact_storage_info <- storage %>% filter(id == artifact$storage_id)
s3_uri <- paste0(artifact_storage_info$root, artifact$key)
cache_dest <- file.path(rappdirs::user_cache_dir("lamindb"), artifact$key)

aws.s3::save_object(
  object = artifact$key,
  bucket = artifact_storage_info$root,
  file = cache_dest,
  base_url = "cellxgene-data-public.s3.amazonaws.com"
)

# use httr to fetch object from s3
httr::GET(s3_uri, httr::write_disk(cache_dest, overwrite = TRUE))
