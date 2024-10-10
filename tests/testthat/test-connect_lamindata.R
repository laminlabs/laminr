test_that("Connecting to lamindata works", {
  temp_lamin_dir <- tempfile()
  temp_lamin_dir2 <- file.path(temp_lamin_dir, ".lamin")
  dir.create(temp_lamin_dir2, recursive = TRUE, showWarnings = FALSE)
  Sys.setenv(LAMIN_SETTINGS_DIR = temp_lamin_dir)
  on.exit({
    unlink(temp_lamin_dir, recursive = TRUE)
    Sys.unsetenv("LAMIN_SETTINGS_DIR")
  })

  # generate user settings
  user_settings <- list(
    email = "null",
    password = "null",
    access_token = "null",
    api_key = "null",
    uid = "00000000",
    uuid = "null",
    handle = "anonymous",
    name = "null"
  )
  user_lines <- paste0("lamin_user_", names(user_settings), "=", unlist(user_settings))
  writeLines(user_lines, file.path(temp_lamin_dir2, "current_user.env"))

  # generate instance settings
  instance_settings <- list(
    owner = "laminlabs",
    name = "lamindata",
    api_url = "https://us-east-1.api.lamin.ai",
    storage_root = "s3://lamindata",
    storage_region = "us-east-1",
    db = "null",
    schema_str = "bionty,wetlab",
    schema_id = "097186c3e91c01ced47aa3e01a3c1515",
    id = "037ba1e08d804f91a90275a47735076a",
    git_repo = "null",
    keep_artifacts_local = "False"
  )
  instance_lines <- paste0("lamindb_instance_", names(instance_settings), "=", unlist(instance_settings))
  writeLines(instance_lines, file.path(temp_lamin_dir2, "current_instance.env"))
  writeLines(instance_lines, file.path(temp_lamin_dir2, "instance--laminlabs--lamindata.env"))

  # try to connect to lamindata
  db <- connect("laminlabs/lamindata")

  # check whether schema was parsed and classes were created
  expect_equal(db$Artifact$name, "artifact")

  # try to fetch a record
  artifact <- db$Artifact$get("mePviem4DGM4SFzvLXf3")

  expect_equal(artifact$uid, "mePviem4DGM4SFzvLXf3")
  expect_equal(artifact$suffix, ".csv")

  # try to fetch linked records
  created_by <- artifact$created_by
  expect_equal(created_by$handle, "sunnyosun")
})
