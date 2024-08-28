# based on: https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/core/_settings_load.py

load_instance_settings <- function(
  instance_settings_file = NULL
) {
  if (is.null(instance_settings_file)) {
    instance_settings_file <- current_instance_settings_file()
  }
  if (!file.exists(instance_settings_file)) {
    stop("No instance is loaded! Call `lamin init` or `lamin load`")
  }
  settings_store <-
    tryCatch({
      parse_instance_settings(instance_settings_file)
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

  setup_instance_from_store(settings_store)
}

load_or_create_user_settings <- function() {
  current_user_settings_file <- current_user_settings_file()

  usettings <-
    if (!file.exists(current_user_settings_file)) {
      warning("using anonymous user (to identify, call `lamin login`)")
      stop("TODO: implement this")
    } else {
      load_user_settings(current_user_settings_file)
    }

  usettings
}

load_user_settings <- function(user_settings_file) {
  settings_store <-
    tryCatch({
      parse_user_settings(user_settings_file)
    }, error = function(e) {
      stop(paste0(
        "Your user settings file is invalid, please delete ",
        user_settings_file, " and log in again."
      ))
    })
  setup_user_from_store(settings_store)
}

setup_instance_from_store <- function(store) {
  # TODO: implement this?
  return(store)
}

setup_user_from_store <- function(store) {
  # TODO: implement this?
  return(store)
}
