test_that("unwrap_python() works", {
  expect_s3_class(unwrap_python(ln), "python.builtin.module")

  expect_s3_class(unwrap_python(ln$ULabel), "lamindb.models.record.Registry")

  df <- data.frame(
    Letters = LETTERS[1:5],
    Numbers = 1:5
  )
  artifact <- ln$Artifact$from_df(df, description = "My data frame")
  expect_s3_class(unwrap_python(artifact), "lamindb.models.artifact.Artifact")
})

test_that("unwrap_args_and_call() works", {
  expect_identical(
    unwrap_args_and_call(
      function(arg, list_arg) {
        c(class(arg)[1], purrr:::map_chr(list_arg, \(.x) {
          class(.x)[1]
        }))
      },
      args = list(
        arg = ln$ULabel,
        list_arg = list(
          ln,
          ln$ULabel
        )
      )
    ),
    c(
      "lamindb.models.record.Registry",
      "python.builtin.module",
      "lamindb.models.record.Registry"
    )
  )
})
