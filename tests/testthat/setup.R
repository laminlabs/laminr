# Run before any tests ---------------------------------------------------------
# Get a unique name for this test run
timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
instance_name <- paste0("laminr-test-", timestamp)
temp_storage <- file.path(tempdir(), instance_name)
# Create a test instance
lamin_init(temp_storage, name = instance_name, modules = "bionty")
# Connect to the test instance
lamin_connect(instance_name)
# Import lamindb so we don't have to do it in every test
ln <- import_lamindb()

# Run after all tests ----------------------------------------------------------
# Delete the test instance
withr::defer(lamin_delete(instance_name, force = TRUE), testthat::teardown_env())
# Reset the default instance so we can connect to another
withr::defer(options(LAMINR_DEFAULT_INSTANCE = NULL), testthat::teardown_env())
