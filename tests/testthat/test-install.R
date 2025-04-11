# Remove the test environment when we are done
test_install_env <- paste0(
  strsplit(get_current_lamin_instance(), "/")[[1]][2],
  "-install"
)
withr::defer(
  reticulate::virtualenv_remove(test_install_env, confirm = FALSE)
)

test_that("install_lamindb() works", {
  expect_no_error(install_lamindb(envname = test_install_env, use = FALSE))
})

test_that("install_lamindb() works with extra packages", {
  expect_no_error(
    install_lamindb(
      envname = test_install_env,
      extra_packages = c("bionty", "wetlab"),
      use = FALSE
    )
  )
})
