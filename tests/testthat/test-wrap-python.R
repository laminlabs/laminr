test_that("wrap_python() works", {
  np <- reticulate::import("numpy", convert = FALSE)
  expect_warning(wrapped_np <- wrap_python(np), "Failed to parse default string")
  expect_s3_class(wrapped_np, "laminr.python.builtin.module")

  ndarray <- np$random$rand(4L, 4L)
  expect_s3_class(ndarray, "numpy.ndarray")

  expect_s3_class(
    wrap_python(ndarray),
    c("laminr.numpy.ndarray", "laminr.WrappedPythonObject")
  )
})

test_that("wrap_python_callable() works", {
  np <- reticulate::import("numpy", convert = FALSE)
  expect_s3_class(np$abs, "numpy.ufunc")

  abs_wrapped <- wrap_python_callable(np$abs)
  expect_s3_class(
    abs_wrapped,
    c("laminr.numpy.ndarray", "laminr.CallableWrappedPythonObject")
  )

  expect_equal(py_to_r(abs_wrapped(-1.1)), 1.1)
})
