if (isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))) {
  # Get a name for this test run
  timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
  test_name <- paste0("laminr-test-", timestamp)

  # Make sure we are using the ephemeral environment with lamindb
  withr::with_envvar(
    c(
      "RETICULATE_USE_MANAGED_VENV" = "yes",
      "LAMINR_LAMINDB_OPTIONS" = "bionty" # Always include bionty for tests
    ),
    {
      require_lamindb()
      reticulate::py_config()
    }
  )

  # Reset the current instance when we are done
  current_instance <- laminr::get_current_lamin_instance()
  withr::defer({
    lc <- laminr::import_module("lamin_cli")
    lc$connect(current_instance)
  }, testthat::teardown_env())

  # Create a temporary test instance
  create_temporary_instance(
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
