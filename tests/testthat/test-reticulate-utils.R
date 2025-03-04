test_that("py_to_r_nonull() works", {
  pd <- reticulate::import("pandas", convert = FALSE)

  df <- pd$DataFrame(list(Letters = LETTERS[1:5], Numbers = 1:5))
  expect_s3_class(df, "pandas.core.frame.DataFrame")

  expect_s3_class(py_to_r_nonull(df), "data.frame")

  expect_invisible(py_to_r_nonull(NULL))
  expect_null(py_to_r_nonull(NULL))
})

test_that("suppress_future_warning() works", {
  py_builtins <- reticulate::import_builtins()
  warnings <- reticulate::import("warnings")

  # NOTE: This will always pass because expect_silent() can't see the output
  # from warnings$warn()
  expect_silent(
    suppress_future_warning(warnings$warn("Warning", py_builtins$FutureWarning))
  )
})
