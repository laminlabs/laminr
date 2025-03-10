if (isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))) {
  # Get a name for this test run
  timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
  test_name <- paste0("laminr-test-", timestamp)

  # Create a new test environment
  install_lamindb(envname = test_name, extra_packages = "bionty")
  if (Sys.getenv("LAMIN_TEST_VERSION") == "devel") {
    reticulate::py_install("git+https://github.com/laminlabs/lamindb.git")
  }
  reticulate::py_config()
  withr::defer(
    {
      tryCatch(
        reticulate::virtualenv_remove(test_name, confirm = FALSE),
        error = function(err) {
          reticulate::conda_remove(test_name)
        }
      )
    },
    testthat::teardown_env()
  )

  # Reset the current instance when we are done
  current_instance <- laminr::get_current_lamin_instance()
  withr::defer(lamin_connect(current_instance), testthat::teardown_env())

  # Create a temporary test instance
  lamin_init_temp(
    test_name,
    modules = "bionty",
    add_timestamp = FALSE,
    envir = testthat::teardown_env()
  )

  # Import lamindb so we don't have to do it in every test
  ln <- import_module("lamindb")
  # Reset the default instance so we can connect to another
  withr::defer(options(LAMINR_DEFAULT_INSTANCE = NULL), testthat::teardown_env())

}
