test_that("getting and setting LAMINR_DEFAULT_INSTANCE works", {
  current_instance <- get_default_instance()
  current_name <- strsplit(current_instance, "/")[[1]][2]
  expect_identical(current_name, instance_name)

  op <- expect_warning(set_default_instance("new/instance"))
  withr::defer(suppressWarnings(options(op)))

  expect_identical(get_default_instance(), "new/instance")
})
