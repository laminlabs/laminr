test_that("getting and setting LAMINR_DEFAULT_INSTANCE works", {
  skip_on_cran()

  default_instance <- get_default_instance()
  current_instance <- get_current_lamin_instance()
  expect_identical(default_instance, current_instance)

  op <- expect_warning(set_default_instance("new/instance"))
  withr::defer(suppressWarnings(options(op)))

  expect_identical(get_default_instance(), "new/instance")
})
