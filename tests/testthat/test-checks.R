test_that("check_requires() works", {
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

test_that("check_requires() works with Python packages", {
  expect_true(
    check_requires("Imported packages", "numpy", language = "Python")
  )

  expect_error(
    check_requires(
      "Missing packages",
      "a_missing_package",
      language = "Python"
    ),
    regexp = "Missing packages requires"
  )

  expect_warning(
    check_requires(
      "Missing packages",
      "a_missing_package",
      alert = "warning",
      language = "Python"
    ),
    regexp = "Missing packages requires"
  )

  expect_message(
    check_requires(
      "Missing packages",
      "a_missing_package",
      alert = "message",
      language = "Python"
    ),
    regexp = "Missing packages requires"
  )

  expect_false(
    check_requires(
      "Missing packages",
      "a_missing_package",
      alert = "none",
      language = "Python"
    )
  )
})

test_that("check_default_instance() works", {
  expect_error(check_default_instance())

  expect_warning(check_default_instance(alert = "warning"))

  expect_message(check_default_instance(alert = "message"))

  expect_true(check_default_instance(alert = "none"))
})

test_that("check_default_instance() works with provided instance", {
  expect_true(check_default_instance(get_current_lamin_instance()))
})

test_that("check_instance_module()", {
  expect_true(check_instance_module("bionty"))

  expect_error(check_instance_module("missing_module"))

  expect_warning(check_instance_module("missing_module", alert = "warning"))

  expect_message(check_instance_module("missing_module", alert = "message"))

  expect_false(check_instance_module("missing_module", alert = "none"))
})
