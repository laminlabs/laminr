import lamindb as ln

artifact = ln.Artifact.get("KBW89Mf7")
artifact
# Artifact(uid='KBW89Mf7IGcekja2hADu', version='2024-07-01', is_latest=True, description='Myeloid compartment', key='cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad', suffix='.h5ad', type='dataset', _accessor='AnnData', size=691757462, hash='SZ5tB0T4YKfiUuUkAL09ZA', _hash_type='md5-n', n_observations=51552, visibility=1, _key_is_virtual=False, created_by_id=1, storage_id=2, transform_id=22, run_id=27, updated_at='2024-07-12 12:40:48 UTC')

adata = artifact.load()
# AnnData object with n_obs × n_vars = 51552 × 36398
#     obs: 'donor_id', 'Predicted_labels_CellTypist', 'Majority_voting_CellTypist', 'Manually_curated_celltype', 'assay_ontology_term_id', 'cell_type_ontology_term_id', 'development_stage_ontology_term_id', 'disease_ontology_term_id', 'self_reported_ethnicity_ontology_term_id', 'is_primary_data', 'organism_ontology_term_id', 'sex_ontology_term_id', 'tissue_ontology_term_id', 'suspension_type', 'tissue_type', 'cell_type', 'assay', 'disease', 'organism', 'sex', 'tissue', 'self_reported_ethnicity', 'development_stage', 'observation_joinid'
#     var: 'gene_symbols', 'feature_is_filtered', 'feature_name', 'feature_reference', 'feature_biotype', 'feature_length'
#     uns: 'cell_type_ontology_term_id_colors', 'citation', 'default_embedding', 'schema_reference', 'schema_version', 'sex_ontology_term_id_colors', 'title'
#     obsm: 'X_umap'