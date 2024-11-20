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

  new_artifact <- db$Artifact$from_path(
    temp_file, description = "laminr test file"
  )

  expect_s3_class(new_artifact, "TemporaryArtifact")
})

test_that("creating an artifact from a directory works", {
  skip_if_not_installed("reticulate")
  skip_if_not(reticulate::py_module_available("lamindb"))

  local_setup_lamindata_instance()

  db <- connect()

  temp_dir <- withr::local_tempdir(pattern = "laminr-test-")
  temp_file <- withr::local_tempfile(
    pattern = "laminr-test-", fileext = ".file", lines = "Test file",
    tmpdir = temp_dir
  )

  new_artifact <- db$Artifact$from_path(
    temp_dir, description = "laminr test directory"
  )

  expect_s3_class(new_artifact, "TemporaryArtifact")
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
