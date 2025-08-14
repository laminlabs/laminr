test_that("laminr_status() returns an S3 object", {
  expect_s3_class(laminr_status(), "laminr_status")
})
