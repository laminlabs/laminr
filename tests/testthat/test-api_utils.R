test_that("api_check_requires works", {
  expect_true(api_check_requires("Imported packages", "cli"))

  expect_error(
    api_check_requires("Missing packages", "a_missing_package"),
    regexp = "Missing packages requires"
  )

  expect_warning(
    api_check_requires("Missing packages", "a_missing_package", alert = "warning"),
    regexp = "Missing packages requires"
  )

  expect_message(
    api_check_requires("Missing packages", "a_missing_package", alert = "message"),
    regexp = "Missing packages requires"
  )

  expect_false(
    api_check_requires("Missing packages", "a_missing_package", alert = "none")
  )
})
