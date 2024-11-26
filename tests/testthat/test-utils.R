test_that("check_requires works", {
  expect_true(check_requires("Imported packages", "cli"))

  expect_error(
    check_requires("Missing packages", "a_missing_package"),
    regexp = "Missing packages requires"
  )

  expect_warning(
    check_requires("Missing packages", "a_missing_package", alert = "warning"),
    regexp = "Missing packages requires"
  )

  expect_message(
    check_requires("Missing packages", "a_missing_package", alert = "message"),
    regexp = "Missing packages requires"
  )

  expect_false(
    check_requires("Missing packages", "a_missing_package", alert = "none")
  )
})
