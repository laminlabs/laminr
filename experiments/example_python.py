import lamindb as ln

# >>> ln.Artifact.
# ln.Artifact.DoesNotExist(                ln.Artifact.from_anndata(                ln.Artifact.links_ethnicity              ln.Artifact.proteins
# ln.Artifact.MultipleObjectsReturned(     ln.Artifact.from_df(                     ln.Artifact.links_experimental_factor    ln.Artifact.replace(
# ln.Artifact.add_to_class(                ln.Artifact.from_dir(                    ln.Artifact.links_feature_set            ln.Artifact.restore(
# ln.Artifact.backed(                      ln.Artifact.from_mudata(                 ln.Artifact.links_gene                   ln.Artifact.run
# ln.Artifact.cache(                       ln.Artifact.from_values(                 ln.Artifact.links_organism               ln.Artifact.run_id
# ln.Artifact.cell_lines                   ln.Artifact.genes                        ln.Artifact.links_pathway                ln.Artifact.save(
# ln.Artifact.cell_markers                 ln.Artifact.get(                         ln.Artifact.links_phenotype              ln.Artifact.search(
# ln.Artifact.cell_types                   ln.Artifact.get_next_by_created_at(      ln.Artifact.links_protein                ln.Artifact.size
# ln.Artifact.collections                  ln.Artifact.get_next_by_updated_at(      ln.Artifact.links_tissue                 ln.Artifact.storage
# ln.Artifact.created_at                   ln.Artifact.get_previous_by_created_at(  ln.Artifact.links_ulabel                 ln.Artifact.storage_id
# ln.Artifact.created_by                   ln.Artifact.get_previous_by_updated_at(  ln.Artifact.load(                        ln.Artifact.suffix
# ln.Artifact.created_by_id                ln.Artifact.hash                         ln.Artifact.lookup(                      ln.Artifact.tissues
# ln.Artifact.delete(                      ln.Artifact.id                           ln.Artifact.mro()                        ln.Artifact.transform
# ln.Artifact.description                  ln.Artifact.input_of_runs                ln.Artifact.n_objects                    ln.Artifact.transform_id
# ln.Artifact.developmental_stages         ln.Artifact.is_latest                    ln.Artifact.n_observations               ln.Artifact.type
# ln.Artifact.df(                          ln.Artifact.key                          ln.Artifact.objects                      ln.Artifact.uid
# ln.Artifact.diseases                     ln.Artifact.links_cell_line              ln.Artifact.open(                        ln.Artifact.ulabels
# ln.Artifact.ethnicities                  ln.Artifact.links_cell_marker            ln.Artifact.organisms                    ln.Artifact.updated_at
# ln.Artifact.experimental_factors         ln.Artifact.links_cell_type              ln.Artifact.params(                      ln.Artifact.using(
# ln.Artifact.feature_sets                 ln.Artifact.links_collection             ln.Artifact.path                         ln.Artifact.version
# ln.Artifact.features(                    ln.Artifact.links_developmental_stage    ln.Artifact.pathways                     ln.Artifact.visibility
# ln.Artifact.filter(                      ln.Artifact.links_disease                ln.Artifact.phenotypes                   

artifact = ln.Artifact.get("KBW89Mf7")
artifact
# Artifact(uid='KBW89Mf7IGcekja2hADu', version='2024-07-01', is_latest=True, description='Myeloid compartment', key='cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad', suffix='.h5ad', type='dataset', _accessor='AnnData', size=691757462, hash='SZ5tB0T4YKfiUuUkAL09ZA', _hash_type='md5-n', n_observations=51552, visibility=1, _key_is_virtual=False, created_by_id=1, storage_id=2, transform_id=22, run_id=27, updated_at='2024-07-12 12:40:48 UTC')

# >>> artifact.
# artifact.DoesNotExist(                artifact.feature_sets(                artifact.links_developmental_stage(   artifact.replace(
# artifact.Meta()                       artifact.features                     artifact.links_disease(               artifact.restore()
# artifact.MultipleObjectsReturned(     artifact.filter(                      artifact.links_ethnicity(             artifact.run
# artifact.add_to_class                 artifact.from_anndata(                artifact.links_experimental_factor(   artifact.run_id
# artifact.adelete(                     artifact.from_db(                     artifact.links_feature_set(           artifact.save(
# artifact.arefresh_from_db(            artifact.from_df(                     artifact.links_gene(                  artifact.save_base(
# artifact.asave(                       artifact.from_dir(                    artifact.links_organism(              artifact.search(
# artifact.backed(                      artifact.from_mudata(                 artifact.links_pathway(               artifact.serializable_value(
# artifact.cache(                       artifact.from_values(                 artifact.links_phenotype(             artifact.size
# artifact.cell_lines(                  artifact.full_clean(                  artifact.links_protein(               artifact.stem_uid
# artifact.cell_markers(                artifact.genes(                       artifact.links_tissue(                artifact.storage
# artifact.cell_types(                  artifact.get(                         artifact.links_ulabel(                artifact.storage_id
# artifact.check(                       artifact.get_constraints()            artifact.load(                        artifact.suffix
# artifact.clean()                      artifact.get_deferred_fields()        artifact.lookup(                      artifact.tissues(
# artifact.clean_fields(                artifact.get_next_by_created_at(      artifact.mro                          artifact.transform
# artifact.collections(                 artifact.get_next_by_updated_at(      artifact.n_objects                    artifact.transform_id
# artifact.created_at                   artifact.get_previous_by_created_at(  artifact.n_observations               artifact.type
# artifact.created_by                   artifact.get_previous_by_updated_at(  artifact.objects                      artifact.uid
# artifact.created_by_id                artifact.hash                         artifact.open(                        artifact.ulabels(
# artifact.date_error_message(          artifact.id                           artifact.organisms(                   artifact.unique_error_message(
# artifact.delete(                      artifact.input_of_runs(               artifact.params                       artifact.updated_at
# artifact.describe(                    artifact.is_latest                    artifact.path                         artifact.using(
# artifact.description                  artifact.key                          artifact.pathways(                    artifact.validate_constraints(
# artifact.developmental_stages(        artifact.labels                       artifact.phenotypes(                  artifact.validate_unique(
# artifact.df(                          artifact.links_cell_line(             artifact.pk                           artifact.version
# artifact.diseases(                    artifact.links_cell_marker(           artifact.prepare_database_save(       artifact.versions
# artifact.ethnicities(                 artifact.links_cell_type(             artifact.proteins(                    artifact.view_lineage(
# artifact.experimental_factors(        artifact.links_collection(            artifact.refresh_from_db(             artifact.visibility

adata = artifact.load()
# AnnData object with n_obs × n_vars = 51552 × 36398
#     obs: 'donor_id', 'Predicted_labels_CellTypist', 'Majority_voting_CellTypist', 'Manually_curated_celltype', 'assay_ontology_term_id', 'cell_type_ontology_term_id', 'development_stage_ontology_term_id', 'disease_ontology_term_id', 'self_reported_ethnicity_ontology_term_id', 'is_primary_data', 'organism_ontology_term_id', 'sex_ontology_term_id', 'tissue_ontology_term_id', 'suspension_type', 'tissue_type', 'cell_type', 'assay', 'disease', 'organism', 'sex', 'tissue', 'self_reported_ethnicity', 'development_stage', 'observation_joinid'
#     var: 'gene_symbols', 'feature_is_filtered', 'feature_name', 'feature_reference', 'feature_biotype', 'feature_length'
#     uns: 'cell_type_ontology_term_id_colors', 'citation', 'default_embedding', 'schema_reference', 'schema_version', 'sex_ontology_term_id_colors', 'title'
#     obsm: 'X_umap'