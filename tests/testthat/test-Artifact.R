artifact <- ln$Artifact$from_df(
  ln$core$datasets$small_dataset1(otype = "DataFrame", with_typo = TRUE),
  key = "my_datasets/rnaseq1.parquet"
)

test_that("Setting description works", {
  expect_null(artifact$description)
  expect_no_error(artifact$description <- "Description")
  expect_identical(artifact$description, "Description")
})
