skip_if_offline()

test_that("df works", {
  local_setup_lamindata_instance()

  db <- connect("laminlabs/lamindata")

  records <- db$Storage$df()

  expect_s3_class(records, "data.frame")
  expect_true(all(c("description", "created_at", "id", "uid") %in% colnames(records)))
})
