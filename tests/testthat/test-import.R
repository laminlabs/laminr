test_that("Importing lamindb works", {
  expect_s3_class(ln, "laminr.python.builtin.module")
})

test_that("Importing bionty works", {
  bt <- import_bionty()

  expect_s3_class(bt, "python.builtin.module")
})
