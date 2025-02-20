# Run before any tests
timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
instance_name <- paste0("laminr-test-", timestamp)
temp_storage <- file.path(tempdir(), instance_name)
lamin_init(temp_storage, name = instance_name, modules = "bionty")
lamin_connect(instance_name)
ln <- import_lamindb()

# Run after all tests
withr::defer(lamin_delete(instance_name, force = TRUE), testthat::teardown_env())
