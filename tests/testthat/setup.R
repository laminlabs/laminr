# Reset the current instance when we are done
current_instance <- laminr::get_current_lamin_instance()
withr::defer(lamin_connect(current_instance), testthat::teardown_env())

# Create a temporary test instance
lamin_init_temp("laminr-test", modules = "bionty", envir = testthat::teardown_env())
# Import lamindb so we don't have to do it in every test
ln <- import_lamindb()
# Reset the default instance so we can connect to another
withr::defer(options(LAMINR_DEFAULT_INSTANCE = NULL), testthat::teardown_env())
