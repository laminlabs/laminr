skip_if_offline()

test_that("RelatedRecord methods work", {
  skip_if_not_logged_in()

  db <- api_connect("laminlabs/lamindata")
  artifact <- db$Artifact$get("mePviem4DGM4SFzvLXf3")
  related <- artifact$experiments

  expect_s3_class(related, "APIRelatedRecords")
  expect_s3_class(related$df(), "data.frame")
  expect_true(length(colnames(related$df())) > 0)
})
