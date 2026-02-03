test_that("Importing a module works", {
  numpy <- import_module("numpy")

  expect_s3_class(numpy, "python.builtin.module")
})

test_that("Importing a non-required module works", {
  scipy <- import_module("scipy")

  expect_s3_class(scipy, "python.builtin.module")
})

test_that("Importing lamindb works", {
  expect_s3_class(ln, "laminr.python.builtin.module")
})

test_that("Importing bionty works", {
  skip_if_not(
    check_requires(
      "Testing imports",
      "bionty",
      language = "Python",
      alert = "none"
    )
  )

  bt <- import_module("bionty")

  expect_s3_class(bt, "python.builtin.module")
})

test_that("Importing pertdb works", {
  skip_if_not(
    check_requires(
      "Testing imports",
      "pertdb",
      language = "Python",
      alert = "none"
    )
  )

  pt <- import_module("pertdb")

  expect_s3_class(wl, "python.builtin.module")
})

test_that("Importing clinicore works", {
  skip_if_not(
    check_requires(
      "Testing imports",
      "clinicore",
      language = "Python",
      alert = "none"
    )
  )

  cc <- import_module("clinicore")

  expect_s3_class(cc, "python.builtin.module")
})
