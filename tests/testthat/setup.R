if (isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))) {
  # Get a name for this test run
  timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
  test_name <- paste0("laminr-test-", timestamp)

  if (Sys.getenv("LAMIN_TEST_VERSION") == "devel") {
    require_module(
      "lamindb",
      options = "bionty",
      source = "git+https://github.com/laminlabs/lamindb.git"
    )
  } else {
    require_module("lamindb", options = "bionty")
  }

  # Make sure we are using the ephemeral environment
  withr::with_envvar(c("RETICULATE_USE_MANAGED_VENV" = "yes"), {
    reticulate::py_config()
  })

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
