library(reticulate)
options(reticulate.traceback = TRUE)

# Set up error handling to display full traceback
options(error = function() {
  cat("\n\n--- FULL PYTHON TRACEBACK ---\n")
  print(reticulate::py_last_error())
  cat("\n--- END TRACEBACK ---\n")
})

library(laminr)

# Access inputs

# Wrap each operation in a tryCatch to see where the error occurs
tryCatch({
  ln <- import_module("lamindb")
  cat("Successfully imported lamindb\n")
  
  ln$track()
  cat("Successfully tracked run\n")
  
  artifact <- ln$Artifact$using("laminlabs/cellxgene")$get("7dVluLROpalzEh8m")
  cat("Successfully retrieved artifact\n")
  
  adata <- artifact$load()
  cat("Successfully loaded artifact\n")
}, error = function(e) {
  cat("\nError occurred:", conditionMessage(e), "\n")
  cat("Python traceback:\n")
  print(reticulate::py_last_error())
})
# Your transformation

library(Seurat)  # find marker genes with Seurat
seurat_obj <- CreateSeuratObject(counts = as(Matrix::t(adata$X), "CsparseMatrix"), meta.data = adata$obs)
seurat_obj[["RNA"]] <- AddMetaData(GetAssay(seurat_obj), adata$var)
Idents(seurat_obj) <- "cell_type"
seurat_obj <- NormalizeData(seurat_obj)
markers <- FindAllMarkers(seurat_obj, features = Features(seurat_obj)[1:100])
seurat_path <- tempfile(fileext = ".rds")
saveRDS(seurat_obj, seurat_path)

# Save outputs

ln$Artifact(seurat_path, key = "my-datasets/my-seurat-object.rds")$save()
ln$Artifact$from_df(markers, key = "my-datasets/my-markers.parquet")$save()
ln$finish()  # finish the run, save source code & run report
