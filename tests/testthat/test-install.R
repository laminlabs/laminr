# Remove the test environment when we are done
withr::defer(
  reticulate::virtualenv_remove(instance_name, confirm = FALSE)
)

test_that("install_lamindb() works", {
  expect_no_error(install_lamindb(envname = instance_name, use = FALSE))
})

test_that("install_lamindb() works with extra packages", {
  expect_no_error(
    install_lamindb(
      envname = instance_name, extra_packages = c("bionty", "wetlab"), use = FALSE
    )
  )
})
