devtools::document()
devtools::load_all(".")


instance_settings <- getOption("lamindb_current_instance")

db <- connect()

db$Artifact


#db$.__enclos_env__$private$classes$core

# db$.__enclos_env__$private$cast_data_to_class("core", "artifact", list())

artifact <- db$Artifact$get("KBW89Mf7IGcekja2hADu")

artifact

artifact$hash

artifact$storage

