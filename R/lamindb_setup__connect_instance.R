# https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/_connect_instance.py

get_owner_name_from_identifier <- function(
  identifier
) {
  if (grepl("/", identifier)) {
    if (grepl("https://lamin.ai/", identifier)) {
      identifier <- gsub("https://lamin.ai/", "", identifier)
    }
    split <- strsplit(identifier, "/")[[1]]
    if (length(split) > 2) {
      stop(
        "The instance identifier needs to be 'owner/name', the instance name",
        " (owner is current user) or the URL: https://lamin.ai/owner/name."
      )
    }
    owner <- split[[1]]
    name <- split[[2]]
  } else {
    stop("TODO: fetch settings from somewhere")
    owner <- settings$user$handle
    name <- identifier
  }
  return(list(owner = owner, name = name))
}


#' Connect to instance
#'
#' @param slug The instance slug `account_handle/instance_name` or URL.
#'   If the instance is owned by you, it suffices to pass the instance name.
#'
#' @export
connect <- function(slug) {
  owner_name <- get_owner_name_from_identifier(slug)
  owner <- owner_name$owner
  name <- owner_name$name

  # ...
}

connect_instance <- function(
  owner, name
) {
  settings_file <- instance_settings_file(name, owner)
  make_hub_request <- TRUE

  if (file.exists(settings_file)) {
    isettings <- load_instance_settings(settings_file)
    make_hub_request <- FALSE
  }
  if (make_hub_request) {
    hub_result <- load_instance_from_hub(owner = owner, name = name)
  }
  # ...
}
