ln <- laminr::import_module("lamindb")  # instantiate the central object of the API

# Access inputs -------------------------------------------

ln$track()
cellxgene_artifacts <- ln$Artifact$connect("laminlabs/cellxgene")
artifact <- cellxgene_artifacts$get("7dVluLROpalzEh8m")
adata <- artifact$load()

# Your transformation -------------------------------------

library(Seurat)
seurat_obj <- CreateSeuratObject(counts = as(Matrix::t(adata$X), "CsparseMatrix"), meta.data = adata$obs)
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
