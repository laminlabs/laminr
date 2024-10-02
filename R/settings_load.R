# based on: https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/core/_settings_load.py
# NOTE: These functions could be moved to a separate lamindb.setup package

.settings_load__load_instance_settings <- function( # nolint object_length_linter
  instance_settings_file = NULL
) {
  if (is.null(instance_settings_file)) {
    instance_settings_file <- .settings_store__current_instance_settings_file()
  }
  if (!file.exists(instance_settings_file)) {
    stop("No instance is loaded! Call `lamin init` or `lamin load`")
  }
  settings_store <-
    tryCatch({
      .settings_store__parse_instance_settings(instance_settings_file)
    }, error = function(e) {
      content <- readLines(instance_settings_file)
      stop(paste0(
        "\n\n", e$message, "\n\n",
        "Your instance settings file with\n\n",
        paste(content, collapse = "\n"), "\n",
        "is invalid (likely outdated), see validation error. ",
        "Please delete ", instance_settings_file, " & ",
        "reload (remote) or re-initialise (local) the instance ",
        "with the same name & storage location."
      ))
    })

  .settings_load__setup_instance_from_store(settings_store)
}

.settings_load__load_or_create_user_settings <- function() { # nolint object_length_linter
  file <- .settings_store__current_user_settings_file()

  if (!file.exists(file)) {
    warning("using anonymous user (to identify, call `lamin login`)")
    stop("TODO: implement this")
  } else {
    .settings_load__load_user_settings(file)
  }
}

.settings_load__load_user_settings <- function(user_settings_file) { # nolint object_length_linter
  settings_store <-
    tryCatch({
      .settings_store__parse_user_settings(user_settings_file)
    }, error = function(e) {
      stop(paste0(
        "Your user settings file is invalid, please delete ",
        user_settings_file, " and log in again."
      ))
    })
  .settings_load__setup_user_from_store(settings_store)
}

.settings_load__setup_instance_from_store <- function(store) { # nolint object_length_linter
  # TODO: implement this?
  return(store)
}

.settings_load__setup_user_from_store <- function(store) { # nolint object_length_linter
  # TODO: implement this?
  return(store)
}
