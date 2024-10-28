test_that("check_requires works", {
  expect_true(check_requires("Imported packages", "cli"))
  expect_error(
    check_requires("Missing packages", "a_missing_package"),
    regexp = "Missing packages requires"
  )
})
