Artifact <- R6::R6Class(
  "Artifact",
  inherit = Record,
  public = list(
    load = function() {
      artifact_accessor <- private$get_value("_accessor")

      file_path <- self$cache()

      if (artifact_accessor == "AnnData") {
        requireNamespace("anndata", quietly = TRUE)
        anndata::read_h5ad(file_path)
      } else {
        cli_abort(paste0("Unsupported accessor: ", artifact_accessor))
      }
    },
    cache = function() {
      # assume that an artifact will have a storage field,
      # and that the storage field will have a type field
      artifact_storage <- private$get_value("storage")
      artifact_key <- private$get_value("key")

      if (artifact_storage$type == "s3") {
        requireNamespace("s3", quietly = TRUE)
        root_dir <- file.path(Sys.getenv("HOME"), ".cache", "lamindb")
        s3::s3_get(
          paste0(artifact_storage$root, "/", artifact_key),
          region = artifact_storage$region,
          data_dir = root_dir
        )
      } else {
        cli_abort(paste0("Unsupported storage type: ", artifact_storage$type))
      }
    }
  )
)
