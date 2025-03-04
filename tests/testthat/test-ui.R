test_that("get_message_fun() returns the correct functions", {
  expect_error(get_message_fun("error")("msg"))

  expect_warning(get_message_fun("warning")("msg"))

  expect_message(get_message_fun("message")("msg"))

  expect_null(get_message_fun("none"))
})
