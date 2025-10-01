test_that("Using a temporary instance works", {
  expect_no_error(
    callr::r(
      function() {
        laminr::use_temporary_instance(name = "temp-instance-test")
        ln <- laminr::import_module("lamindb")
        df <- ln$core$datasets$small_dataset1(otype = "DataFrame")
        artifact <- ln$Artifact$from_dataframe(df, key = "test.parquet")$save()
      },
      package = "laminr"
    )
  )
})
