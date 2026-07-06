test_that("escape_r_argument_name() escapes non-syntactic names", {
  expect_equal(escape_r_argument_name("instance"), "instance")
  expect_equal(escape_r_argument_name("df"), "df")
  expect_equal(escape_r_argument_name("..."), "...")
  expect_equal(escape_r_argument_name("_instance_info"), "`_instance_info`")
  expect_equal(escape_r_argument_name("in"), "`in`")
  expect_equal(escape_r_argument_name("2d"), "`2d`")
})

test_that("make_argument_defaults_string() escapes underscore-prefixed names", {
  args <- list(
    instance = "__NODEFAULT__",
    `_instance_info` = "NULL",
    `...` = "..."
  )

  result <- make_argument_defaults_string(args)
  expect_equal(result, "instance, `_instance_info` = NULL, ...")

  # The result must be parseable as an R function signature
  expect_error(
    eval(parse(text = paste0("function(", result, ") NULL"))),
    NA
  )
})

test_that("make_argument_usage_string() escapes underscore-prefixed names", {
  args <- list(
    instance = "__NODEFAULT__",
    `_instance_info` = "NULL",
    `...` = "..."
  )

  result <- make_argument_usage_string(args)
  expect_equal(result, "instance = instance, `_instance_info` = `_instance_info`, ...")
})

test_that("make_wrapper_function() handles underscore-prefixed arguments", {
  args <- list(
    instance = "__NODEFAULT__",
    `_instance_info` = "NULL",
    `...` = "..."
  )

  # This previously threw an R parse error, silently dropping wrapped registries
  expect_error(
    wrapper <- make_wrapper_function("identity", args),
    NA
  )
  expect_true(is.function(wrapper))
  expect_true("_instance_info" %in% names(formals(wrapper)))
})
