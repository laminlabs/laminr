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

test_that("creating an artifact from a file works", {
  skip_if_not_installed("reticulate")
  skip_if_not(reticulate::py_module_available("lamindb"))

  local_setup_lamindata_instance()

  db <- connect()

  temp_file <- withr::local_tempfile(
    pattern = "laminr-test-", fileext = ".file", lines = "Test file"
  )

  new_record <- db$Artifact$from_file(
    temp_file, description = "laminr test file"
  )

  expect_s3_class(new_artifact, "TemporaryArtifact")
})

test_that("creating artifacts from a directory works", {
  skip_if_not_installed("reticulate")
  skip_if_not(reticulate::py_module_available("lamindb"))

  local_setup_lamindata_instance()

  db <- connect()

  temp_dir <- withr::local_tempdir()
  temp_file1 <- withr::local_tempfile(
    pattern = "laminr-test-", fileext = ".file", lines = "Test file 1",
    tmpdir = temp_dir
  )
  temp_file1 <- withr::local_tempfile(
    pattern = "laminr-test-", fileext = ".file", lines = "Test file 2",
    tmpdir = temp_dir
  )

  new_records <- db$Artifact$from_dir(temp_dir)

  expect_true(is.list(new_records))
  expect_length(new_records, 2)
  expect_s3_class(new_records[[1]], "TemporaryArtifact")
  expect_s3_class(new_records[[2]], "TemporaryArtifact")
})

test_that("creating an artifact from an AnnData works", {
  skip_if_not_installed("reticulate")
  skip_if_not(reticulate::py_module_available("lamindb"))
  skip_if_not_installed("anndata")

  local_setup_lamindata_instance()

  db <- connect()

  adata <- anndata::AnnData(
    X = matrix(rnorm(10 * 20), nrow = 10, ncol = 20),
    obs = data.frame(Letter = LETTERS[1:10]),
    uns = list(Description = "laminr test AnnData")
  )

  new_artifact <- db$Artifact$from_df(
    adata, description = adata$uns$Description
  )

  expect_s3_class(new_artifact, "TemporaryArtifact")
})
