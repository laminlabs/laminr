ln <- laminr::import_module("lamindb")  # instantiate the central object of the API

# Access inputs -------------------------------------------

ln$track()  # track your run of a notebook or script
artifact <- ln$Artifact$using("laminlabs/cellxgene")$get("7dVluLROpalzEh8m")  # query the artifact https://lamin.ai/laminlabs/cellxgene/artifact/7dVluLROpalzEh8m
adata <- artifact$load()  # load the artifact into memory or sync to cache via filepath <- artifact$cache()

# Your transformation -------------------------------------

library(Seurat)  # find marker genes with Seurat
seurat_obj <- CreateSeuratObject(counts = as(Matrix::t(adata$X), "CsparseMatrix"), meta.data = adata$obs)
seurat_obj[["RNA"]] <- AddMetaData(GetAssay(seurat_obj), adata$var)
Idents(seurat_obj) <- "cell_type"
seurat_obj <- NormalizeData(seurat_obj)
markers <- FindAllMarkers(seurat_obj, features = Features(seurat_obj)[1:100])
seurat_path <- tempfile(fileext = ".rds")
saveRDS(seurat_obj, seurat_path)

# Save outputs --------------------------------------------

ln$Artifact(seurat_path, key = "my-datasets/my-seurat-object.rds")$save()  # save versioned output
ln$Artifact$from_df(markers, key = "my-datasets/my-markers.parquet")$save()  # save versioned output
ln$finish()  # finish the run, save source code & run report
