skip_if_offline()
skip()

test_that("Connecting to lamindata works", {
  skip_if_not_logged_in()

  # try to connect to lamindata
  db <- api_connect("laminlabs/lamindata")

  # check whether schema was parsed and classes were created
  expect_equal(db$Artifact$name, "artifact")

  # try to fetch a record
  artifact <- db$Artifact$get("mePviem4DGM4SFzvLXf3")

  expect_equal(artifact$uid, "mePviem4DGM4SFzvLXf3")
  expect_equal(artifact$suffix, ".csv")

  # try to fetch related field
  created_by <- artifact$created_by
  expect_equal(created_by$handle, "sunnyosun")

  # access a related field which is empty for this record
  expect_null(artifact$type) # one to one

  expect_s3_class(artifact$wells, "APIRelatedRecords") # one-to-many
})

test_that("Connecting to a private instance works", {
  skip_if_not_logged_in()

  db <- api_connect("laminlabs/lamin-dev")

  instance_settings <- db$get_settings()
  expect_equal(instance_settings$name, "lamin-dev")
})
