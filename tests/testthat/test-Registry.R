skip_if_offline()

test_that("df works", {
  local_setup_lamindata_instance()

  db <- connect("laminlabs/lamindata")

  records <- db$Storage$df()

  expect_s3_class(records, "data.frame")
  expect_true(all(c("description", "created_at", "id", "uid") %in% colnames(records)))
})

test_that("to_string works", {
  local_setup_lamindata_instance()

  db <- connect("laminlabs/lamindata")

  str <- db$bionty$Phenotype$to_string()
  # example:
  # nolint start line_length_linter
  # Phenotype(SimpleFields=[id, uid, abbr, name, synonyms, created_at, updated_at, description, ontology_id], RelationalFields=[run, artifacts, created_by], BiontyFields=[source, parents, children])
  # nolint end line_length_linter

  expect_type(str, "character")

  expect_match(str, "Phenotype\\([^\\)]+\\)")
  expect_match(str, "SimpleFields=\\[id, uid,[^\\]*\\]")
  expect_match(str, "RelationalFields=\\[[^\\]*\\]")
  expect_match(str, "BiontyFields=\\[[^\\]*\\]")
})
