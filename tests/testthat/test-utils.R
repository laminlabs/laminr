test_that("getting and setting LAMINR_DEFAULT_INSTANCE works", {
  current_instance <- get_current_lamin_instance()
  op <- set_default_instance(current_instance)
  withr::defer(suppressWarnings(options(op)))

  default_instance <- get_default_instance()
  expect_identical(default_instance, current_instance)

  expect_warning(set_default_instance("new/instance"))

  expect_identical(get_default_instance(), "new/instance")
})

test_that("Lamin colors are disabled through lamindb_setup", {
  withr::local_options(list(LAMINR_COLORS_DISABLED = NULL))

  py_lamin_logger <- new.env(parent = emptyenv())
  py_lamin_logger$LEVEL_TO_COLORS <- list("40" = "red")
  py_lamin_logger$RESET_COLOR <- "reset"

  testthat::local_mocked_bindings(
    check_in_knitr_notebook = function(...) TRUE,
    import_lamin_logger_module = function() py_lamin_logger
  )

  expect_true(disable_lamin_colors())
  expect_named(py_lamin_logger$LEVEL_TO_COLORS, character(0))
  expect_length(py_lamin_logger$LEVEL_TO_COLORS, 0)
  expect_identical(py_lamin_logger$RESET_COLOR, "")
})
