test_that("Coercing BasicQuerySet to list works", {
  collection <- ln$Collection$connect("laminlabs/cellxgene")$get("3eYxM8IjTZVOrbvXPIJ4")
  expect_no_error(collection_list <- as.list(collection))
  expect_true(is.list(collection_list))
})
