local_setup_lamindata_instance <- function(env = parent.frame()) {
  root_dir <- withr::local_file(tempfile(), .local_envir = env)
  withr::local_envvar(c(LAMIN_SETTINGS_DIR = root_dir), .local_envir = env)

  # create a temporary directory for the settings
  lamin_dir <- file.path(root_dir, ".lamin")
  dir.create(lamin_dir, recursive = TRUE, showWarnings = FALSE)

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
  writeLines(user_lines, file.path(lamin_dir, "current_user.env"))

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
  writeLines(instance_lines, file.path(lamin_dir, "current_instance.env"))
  writeLines(instance_lines, file.path(lamin_dir, "instance--laminlabs--lamindata.env"))

  root_dir
}
