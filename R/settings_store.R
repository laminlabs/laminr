# based on: https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/core/_settings_store.py
# NOTE: These functions could be moved to a separate lamindb.setup package

.settings_store__get_settings_dir <- function() { # nolint object_length_linter
  settings_dir <- Sys.getenv("LAMIN_SETTINGS_DIR")

  if (settings_dir != "") {
    file.path(settings_dir, ".lamin")
  } else {
    file.path(Sys.getenv("HOME"), ".lamin")
  }
}

.settings_store__get_settings_file_name_prefix <- function() { # nolint object_length_linter
  lamin_env <- Sys.getenv("LAMIN_ENV")
  if (lamin_env != "" && lamin_env != "prod") {
    paste0(lamin_env, "--")
  } else {
    ""
  }
}

.settings_store__current_instance_settings_file <- function() { # nolint object_length_linter
  settings_dir <- .settings_store__get_settings_dir()
  settings_file_name_prefix <- .settings_store__get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "current_instance.env"))
}

.settings_store__current_user_settings_file <- function() { # nolint object_length_linter
  settings_dir <- .settings_store__get_settings_dir()
  settings_file_name_prefix <- .settings_store__get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "current_user.env"))
}

.settings_store__instance_settings_file <- function(name, owner) { # nolint object_length_linter
  settings_dir <- .settings_store__get_settings_dir()
  settings_file_name_prefix <- .settings_store__get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "instance--", owner, "--", name, ".env"))
}

.settings_store__user_settings_file_email <- function(email) { # nolint object_length_linter
  settings_dir <- .settings_store__get_settings_dir()
  settings_file_name_prefix <- .settings_store__get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "user--", email, ".env"))
}

.settings_store__user_settings_file_handle <- function(handle) { # nolint object_length_linter
  settings_dir <- .settings_store__get_settings_dir()
  settings_file_name_prefix <- .settings_store__get_settings_file_name_prefix()
  file.path(settings_dir, paste0(settings_file_name_prefix, "user--", handle, ".env"))
}

.settings_store__system_storage_settings_file <- function() { # nolint object_length_linter
  settings_dir <- .settings_store__get_settings_dir()
  file.path(settings_dir, "storage.env")
}

# nolint start: object_length_linter
.settings_store__read_typed_env <- function(
    # nolint end: object_length_linter
    env_file,
    env_prefix,
    field_types) {
  env <- readLines(env_file)

  # remove comments
  env2 <- env[!grepl("^#", env)]

  # remove empty lines
  env3 <- env2[env2 != ""]

  parsed <- map(env3, function(x) {
    x_split <- strsplit(x, "=")[[1]]

    if (length(x_split) != 2) {
      cli_abort(paste0("Invalid line: ", x))
    }

    name_with_prefix <- x_split[[1]]
    raw_value <- x_split[[2]]

    if (!grepl(env_prefix, name_with_prefix)) {
      cli_abort(paste0("Invalid prefix: ", name_with_prefix))
    }
    name <- gsub(env_prefix, "", name_with_prefix)

    if (!name %in% names(field_types)) {
      cli_abort(paste0("Unknown field: ", name))
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
        cli_abort(paste0("Unknown type: ", type))
      }

    list(name = name, value = value)
  })

  values <- map(parsed, "value")
  names <- map_chr(parsed, "name")

  set_names(values, names)
}

.settings_store__parse_instance_settings <- function(env_file) { # nolint object_length_linter
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

  .settings_store__read_typed_env(env_file, env_prefix, field_types)
}

.settings_store__parse_user_settings <- function(env_file) { # nolint object_length_linter
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

  .settings_store__read_typed_env(env_file, env_prefix, field_types)
}
