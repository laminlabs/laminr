ln <- laminr::import_module("lamindb") # instantiate the central object of the API

# Access inputs -------------------------------------------

ln$track()

# --- DEBUG: why is ln$Artifact NULL on the dev build? ---
cat("=== DEBUG START ===\n")

# Raw (converting) module, exactly what wrap_lamindb() iterates over
py_lamindb <- reticulate::import("lamindb")
cat(
  "raw __version__:",
  tryCatch(
    reticulate::py_to_r(reticulate::py_get_attr(py_lamindb, "__version__")),
    error = function(e) paste("ERR:", conditionMessage(e))
  ),
  "\n"
)
cat("'Artifact' %in% names(py_lamindb):", "Artifact" %in% names(py_lamindb), "\n")
cat("'DB' %in% names(py_lamindb):", "DB" %in% names(py_lamindb), "\n")

# Reproduce the access that wrap_python() does in its loop (this is where the
# error is being silently swallowed via try())
cat("--- reproducing py_lamindb[['Artifact']] ---\n")
tryCatch(
  {
    a <- py_lamindb[["Artifact"]]
    cat("Artifact access OK; class:", paste(class(a), collapse = ", "), "\n")
  },
  error = function(e) {
    cat("Artifact access ERROR:", conditionMessage(e), "\n")
    py_err <- tryCatch(reticulate::py_last_error(), error = function(e2) NULL)
    if (!is.null(py_err)) {
      cat("Python error type:", py_err$type, "\n")
      cat("Python error message:", py_err$message, "\n")
    }
  }
)

# Python metaclass chain of Artifact (S3 dispatch for py_to_r keys off this).
# If the "...Registry" path changed in dev, wrap_registry() won't be reached.
py_lamindb_nc <- reticulate::import("lamindb", convert = FALSE)
art_nc <- tryCatch(
  reticulate::py_get_attr(py_lamindb_nc, "Artifact"),
  error = function(e) {
    cat("py_get_attr(Artifact) ERROR:", conditionMessage(e), "\n")
    NULL
  }
)
if (!is.null(art_nc)) {
  cat("Artifact R class chain:", paste(class(art_nc), collapse = " | "), "\n")
  cat("'connect' %in% names(Artifact):", "connect" %in% names(art_nc), "\n")
}
cat("=== DEBUG END ===\n")

cellxgene_artifacts <- ln$Artifact$connect("laminlabs/cellxgene")
artifact <- cellxgene_artifacts$get("7dVluLROpalzEh8m")
adata <- artifact$load()

# Your transformation -------------------------------------

library(Seurat)
seurat_obj <- CreateSeuratObject(
  counts = as(Matrix::t(adata$X), "CsparseMatrix"),
  meta.data = adata$obs
)
seurat_obj[["RNA"]] <- AddMetaData(GetAssay(seurat_obj), adata$var)
Idents(seurat_obj) <- "cell_type"
seurat_obj <- NormalizeData(seurat_obj)
markers <- FindAllMarkers(seurat_obj, features = Features(seurat_obj)[1:100])
seurat_path <- tempfile(fileext = ".rds")
saveRDS(seurat_obj, seurat_path)

# Save outputs --------------------------------------------

ln$Artifact(seurat_path, key = "my-datasets/my-seurat-object.rds")$save()
ln$Artifact$from_df(markers, key = "my-datasets/my-markers.parquet")$save()
ln$finish()
