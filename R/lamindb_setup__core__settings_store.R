# based on: https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/core/_settings_store.py

get_settings_dir <- function() {
  settings_dir <- Sys.getenv("LAMIN_SETTINGS_DIR")

  if (settings_dir != "") {
    file.path(settings_dir, ".lamin")
  } else {
    file.path(Sys.getenv("HOME"), ".lamin")
  }
}

get_settings_file_name_prefix <- function() {
  lamin_env <- Sys.getenv("LAMIN_ENV")
  if (lamin_env != "" && lamin_env != "prod") {
    paste0(lamin_env, "--")
  } else {
    ""
  }
}

current_instance_settings_file <- function() {
  settings_dir <- get_settings_dir()
  settings_file_name_prefix <- get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "current_instance.env"))
}

current_user_settings_file <- function() {
  settings_dir <- get_settings_dir()
  settings_file_name_prefix <- get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "current_user.env"))
}

instance_settings_file <- function(name, owner) {
  settings_dir <- get_settings_dir()
  settings_file_name_prefix <- get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "instance--", owner, "--", name, ".env"))
}

user_settings_file_email <- function(email) {
  settings_dir <- get_settings_dir()
  settings_file_name_prefix <- get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "user--", email, ".env"))
}

user_settings_file_handle <- function(handle) {
  settings_dir <- get_settings_dir()
  settings_file_name_prefix <- get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "user--", handle, ".env"))
}

system_storage_settings_file <- function() {
  settings_dir <- get_settings_dir()
  file.path(settings_dir, "storage.env")
}

settings_store__read_typed_env <- function(
  env_file,
  env_prefix,
  field_types
) {
  env <- readLines(env_file)

  # remove comments
  env2 <- env[!grepl("^#", env)]

  # remove empty lines
  env3 <- env2[env2 != ""]

  parsed <- lapply(env3, function(x) {
    x_split <- strsplit(x, "=")[[1]]

    if (length(x_split) != 2) {
      stop("Invalid line: ", x)
    }

    name_with_prefix <- x_split[[1]]
    raw_value <- x_split[[2]]

    if (!grepl(env_prefix, name_with_prefix)) {
      stop("Invalid prefix: ", name_with_prefix)
    }
    name <- gsub(env_prefix, "", name_with_prefix)

    if (!name %in% names(field_types)) {
      stop("Unknown field: ", name)
    }
    raw_type <- field_types[[name]]

    optional <- grepl("Optional\\[.*\\]", raw_type)
    type <- gsub("Optional\\[(.*)\\]", "\\1", raw_type)

    value <-
      if (optional && raw_value == "null") {
        NULL
      } else if (type == "str") {
        raw_value
      } else if (type == "int") {
        as.integer(raw_value)
      } else if (type == "float") {
        as.numeric(raw_value)
      } else if (type == "bool") {
        as.logical(raw_value)
      } else {
        stop("Unknown type: ", type)
      }
    
    list(name = name, value = value)
  })

  values <- sapply(parsed, function(x) {
    x$value
  })
  names <- sapply(parsed, function(x) {
    x$name
  })

  setNames(values, names)
}

parse_instance_settings <- function(env_file) {
  env_prefix <- "lamindb_instance_"

  field_types <- list(
    owner = "str",
    name = "str",
    storage_root = "str",
    storage_region = "str",
    db = "Optional[str]",
    schema_str = "Optional[str]",
    id = "str",
    git_repo = "Optional[str]",
    keep_artifacts_local = "Optional[bool]"
  )

  settings_store__read_typed_env(env_file, env_prefix, field_types)
}

parse_user_settings <- function(env_file) {
  env_prefix <- "lamin_user_"

  field_types <- list(
    email = "str",
    password = "str",
    access_token = "str",
    uid = "str",
    uuid = "str",
    handle = "str",
    name = "str"
  )

  settings_store__read_typed_env(env_file, env_prefix, field_types)
}
