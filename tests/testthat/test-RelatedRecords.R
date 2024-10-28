skip_if_offline()

test_that("RelatedRecord methods work", {
  local_setup_lamindata_instance()

  db <- connect("laminlabs/lamindata")
  artifact <- db$Artifact$get("mePviem4DGM4SFzvLXf3")
  related <- artifact$experiments

  expect_s3_class(related, "RelatedRecords")
  expect_s3_class(related$df(), "data.frame")
  expect_true(length(colnames(related$df())) > 0)
  expect_s3_class(related$field, "Field")
})
