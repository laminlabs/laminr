# Remove the test environment when we are done
test_install_env <- paste0(
  "laminr-test-install-",
  format(Sys.time(), "%Y%m%d%H%M%S")
)
withr::defer(
  reticulate::virtualenv_remove(test_install_env, confirm = FALSE)
)

test_that("install_lamindb() works", {
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_no_error(install_lamindb(envname = test_install_env, use = FALSE))
})

test_that("install_lamindb() works with extra packages", {
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_no_error(
    install_lamindb(
      envname = test_install_env,
      extra_packages = c("bionty", "pertdb"),
      use = FALSE
    )
  )
})

# nolint start commented_code_linter
# Recommended to have something like
# test_that("add_two is deprecated", {
#   expect_snapshot(install_lamindb(envname = test_install_env, use = FALSE))
# })
# But the output is likely not stable enough to work
# nolint end commented_code_linter
