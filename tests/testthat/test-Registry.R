skip_on_cran()

test_that("Wrapping a Registry works", {
  expect_s3_class(ln$ULabel, "laminr.lamindb.models.record.Registry")
})

test_that("Calling a Registry works", {
  label <- expect_no_error(ln$ULabel(name = "My label"))

  expect_s3_class(label, "lamindb.models.ulabel.ULabel")
})

test_that("Registry$from_df() works", {
  df <- data.frame(
    Letters = LETTERS[1:5],
    Numbers = 1:5
  )
  artifact <- expect_no_error(
    ln$Artifact$from_df(df, description = "My data frame")
  )
  expect_s3_class(artifact, "laminr.lamindb.models.artifact.Artifact")

  df <- data.frame(
    Letters = letters[1:5],
    Numbers = 1:5
  )
  artifact <- expect_no_error(
    ln$Artifact$from_df(df, revises = artifact)
  )
  expect_s3_class(artifact, "laminr.lamindb.models.artifact.Artifact")
})
