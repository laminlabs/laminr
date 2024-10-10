skip_if_offline()

test_that("Connecting to lamindata works", {
  local_setup_lamindata_instance()

  # try to connect to lamindata
  db <- connect("laminlabs/lamindata")

  # check whether schema was parsed and classes were created
  expect_equal(db$Artifact$name, "artifact")

  # try to fetch a record
  artifact <- db$Artifact$get("mePviem4DGM4SFzvLXf3")

  expect_equal(artifact$uid, "mePviem4DGM4SFzvLXf3")
  expect_equal(artifact$suffix, ".csv")

  # try to fetch linked records
  created_by <- artifact$created_by
  expect_equal(created_by$handle, "sunnyosun")
})
