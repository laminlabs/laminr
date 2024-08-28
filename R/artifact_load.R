artifact_load <- function(artifact) {
  if (!is(artifact, "Artifact")) {
    stop("artifact must be an Artifact object")
  }

  requireNamespace("anndata", quietly = TRUE)

  file_path <- artifact_download(artifact)

  accessor <- artifact$`_accessor`

  if (accessor == "AnnData") {
    anndata::read_h5ad(file_path)
  } else {
    stop("Unsupported accessor: ", accessor)
  }
}

artifact_download <- function(artifact) {
  if (!is(artifact, "Artifact")) {
    stop("artifact must be an Artifact object")
  }

  requireNamespace("s3", quietly = TRUE)

  storage <- artifact$storage

  type <- storage$type

  if (type == "s3") {
    # ~/.cache/lamindb
    local_path <- file.path(
      Sys.getenv("HOME"),
      ".cache",
      "lamindb",
      gsub("^s3://", "", storage$root),
      artifact$key
    )
    if (!file.exists(local_path)) {
      workaround <- s3::s3_get(
        paste0(storage$root, "/", artifact$key),
        local_path,
        region = storage$region
      )
      file.rename(workaround, local_path)
    }

    local_path
  } else {
    stop("Unsupported storage type: ", type)
  }
}