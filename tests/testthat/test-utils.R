test_that("getting and setting LAMINR_DEFAULT_INSTANCE works", {
  current_instance <- get_current_lamin_instance()
  op <- set_default_instance(current_instance)
  withr::defer(suppressWarnings(options(op)))

  default_instance <- get_default_instance()
  expect_identical(default_instance, current_instance)

  expect_warning(set_default_instance("new/instance"))

  expect_identical(get_default_instance(), "new/instance")
})
