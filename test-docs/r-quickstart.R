ln <- laminr::import_module("lamindb") # instantiate the central object of the API

# Access inputs -------------------------------------------

ln$track()

# --- DEBUG: inspect Artifact.connect on the dev build ---
cat("=== DEBUG START ===\n")
cat("lamindb version:", ln$`__version__`, "\n")
cat("class(ln$Artifact):", paste(class(ln$Artifact), collapse = ", "), "\n")
connect_attr <- tryCatch(
  ln$Artifact$connect,
  error = function(e) {
    cat("Error accessing ln$Artifact$connect:", conditionMessage(e), "\n")
    NULL
  }
)
cat("is.null(connect_attr):", is.null(connect_attr), "\n")
cat("is.function(connect_attr):", is.function(connect_attr), "\n")
cat("class(connect_attr):", paste(class(connect_attr), collapse = ", "), "\n")
cat("py type of connect:", tryCatch(
  reticulate::py_to_r(reticulate::py_get_attr(
    reticulate::py_get_attr(ln$Artifact, "connect"), "__class__"
  ))$`__name__`,
  error = function(e) paste("ERR:", conditionMessage(e))
), "\n")
cat("has ln$DB:", !is.null(tryCatch(ln$DB, error = function(e) NULL)), "\n")
cat("dir(ln$Artifact) has connect:", "connect" %in% tryCatch(
  reticulate::py_to_r(reticulate::py_get_attr(ln$Artifact, "__dir__")()),
  error = function(e) character(0)
), "\n")
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
