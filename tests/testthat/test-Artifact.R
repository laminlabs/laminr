skip_if_offline()

test_that("creating an artifact from a data frame works", {
  skip_if_not_installed("reticulate")
  skip_if_not(reticulate::py_module_available("lamindb"))

  local_setup_lamindata_instance()

  db <- connect()

  dataframe <- data.frame(
    Description = "laminr test data frame",
    Timestamp = Sys.time()
  )

  new_artifact <- db$Artifact$from_df(
    dataframe, description = dataframe$Description
  )

  expect_s3_class(new_artifact, "TemporaryArtifact")
})
