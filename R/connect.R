# https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/_connect_instance.py
# NOTE: These functions could be moved to a separate lamindb.setup package

#' Connect to instance
#'
#' Note that prior to connecting to an instance, you need to authenticate with
#' `lamin login`. If no slug is provided, the default instance is loaded, which is
#' set by running `lamin connect <slug>`.
#'
#' @param slug The instance slug `account_handle/instance_name` or URL.
#'   If the instance is owned by you, it suffices to pass the instance name.
#'   If no slug is provided, the default instance is loaded.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # first run 'lamin login' to authenticate
#' instance <- connect("laminlabs/cellxgene")
#' instance
#' }
connect <- function(slug = NULL) {
  user_settings <- .get_user_settings()

  instance_file <-
    if (is.null(slug)) {
      # if the slug is null, see if we can load the default instance
      .settings_store__current_instance_settings_file()
    } else {
      # if the slug is not null, try to load the instance from the local settings
      owner_name <- .connect_get_owner_name_from_identifier(slug)

      .settings_store__instance_settings_file(
        name = owner_name$name,
        owner = owner_name$owner
      )
    }

  instance_settings <-
    if (file.exists(instance_file)) {
      .settings_load__load_instance_settings(instance_file)
    } else {
      # try to load the user settings from the api
      user_file <- .settings_store__current_user_settings_file()

      if (!file.exists(user_file) || is.null(slug)) {
        error_msg <-
          if (is.null(slug)) {
            paste0(
              "Could not load default instance. Either:\n",
              " - Provide a slug. For example: `connect(\"laminlabs/cellxgene\")`)\n",
              " - Set a default instance by running `lamin connect <slug>`."
            )
          } else {
            paste0(
              "No default user or instance is loaded! Either:\n",
              " - Call `lamin login` to set a default user.\n",
              " - Call `lamin connect <slug>` to set a default instance."
            )
          }
        cli_abort(error_msg)
      } else {
        user_settings <- .settings_load__load_user_settings(user_file)

        owner_name <- .connect_get_owner_name_from_identifier(slug)

        .connect_get_instance_settings(
          owner = owner_name$owner,
          name = owner_name$name,
          access_token = user_settings$access_token
        )
      }
    }

  for (required_field in c("id", "api_url", "schema_id")) {
    if (is.null(instance_settings[[required_field]])) {
      cli_abort(paste0(
        "Invalid instance settings: missing field '", required_field, "'\n",
        "Your instance settings file is likely outdated. Please update lamin-cli,\n",
        "delete the instance settings file, and reload the instance."
      ))
    }
  }

  is_default <- FALSE
  if (is.null(slug)) {
    instance_slug <- paste0(
      instance_settings$owner, "/",
      name = instance_settings$name
    )
    current_default <- getOption("LAMINR_DEFAULT_INSTANCE")
    if (!is.null(current_default)) {
      if (!identical(instance_slug, current_default)) {
        cli::cli_abort(c(
          "There is already a default instance {.field {current_default}}",
          "i" = "To connect to another instance provide a slug"
        ))
      }
    } else {
      options(LAMINR_DEFAULT_INSTANCE = instance_slug)
    }
    is_default <- TRUE
  }

  create_instance(instance_settings, is_default)
}

# nolint start: object_length_linter
.connect_get_owner_name_from_identifier <- function(
    # nolint end: object_length_linter
    identifier) {
  if (grepl("/", identifier)) {
    if (grepl("https://lamin.ai/", identifier)) {
      identifier <- gsub("https://lamin.ai/", "", identifier)
    }
    split <- strsplit(identifier, "/")[[1]]
    if (length(split) > 2) {
      cli_abort(paste0(
        "The instance identifier needs to be 'owner/name', the instance name",
        " (owner is current user) or the URL: https://lamin.ai/owner/name."
      ))
    }
    owner <- split[[1]]
    name <- split[[2]]
  } else {
    user_settings <- .get_user_settings()

    owner <- user_settings$handle
    name <- identifier
  }
  return(list(owner = owner, name = name))
}


.connect_get_instance_settings <- function(owner, name, access_token) { # nolint object_length_linter
  supabase_url <- "https://hub.lamin.ai"
  function_name <- "get-instance-settings-v1"

  body_data <- list(owner = owner, name = name)
  body <-
    if (length(body_data) > 0) {
      jsonlite::toJSON(body_data)
    } else {
      "{}"
    }

  url <- paste0(
    supabase_url,
    "/functions/v1/",
    function_name
  )

  request <- httr::POST(
    url,
    httr::add_headers(
      Authorization = paste0("Bearer ", access_token),
      `Content-Type` = "application/json"
    ),
    body = body
  )
  content <- process_httr_response(request, "connect to instance")

  if (length(content) == 0) {
    cli_abort(paste0("Instance '", owner, "/", name, "' not found"))
  }

  InstanceSettings$new(content)
}

#' Set the default LaminDB instance
#'
#' Set the default LaminDB instance by calling `lamin connect` on the command
#' line
#'
#' @param slug Slug giving the instance to connect to ("<owner>/<name>")
#'
#' @export
#'
#' @examples
#' \dontrun{
#' lamin_connect("laminlabs/cellxgene")
#' }
lamin_connect <- function(slug) {
  current_default <- getOption("LAMINR_DEFAULT_INSTANCE")
  if (!is.null(current_default)) {
    cli::cli_abort(c(
      "There is already a default instance connected ({.field {current_default}})",
      "x" = "{.code lamin connect} will not be run"
    ))
  }

  # Set the default environment if not set
  reticulate::use_virtualenv("r-lamindb", required = FALSE)
  if (!reticulate::py_available()) {
    # Force reticulate to connect to Python
    py_config <- reticulate::py_config() # nolint object_usage_linter
  }

  system2("lamin", paste("connect", slug))
}

#' Login to LaminDB
#'
#' Login as a LaminDB user
#'
#' @param user Handle for the user to login as
#' @param api_key API key for a user
#'
#' @details
#' Setting `user` will run `lamin login <user>`. Setting `api_key` will set the
#' `LAMIN_API_KEY` environment variable tempoarily with `withr::with_envvar()`
#' and run `lamin login`. If neither `user` or `api_key` are set `lamin login`
#' will be run if `LAMIN_API_KEY` is set.
#'
#'
#' @export
lamin_login <- function(user = NULL, api_key = NULL) {
  current_default <- getOption("LAMINR_DEFAULT_INSTANCE")
  if (!is.null(current_default)) {
    cli::cli_abort(c(
      "There is already a default instance connected ({.field {current_default}})",
      "x" = "{.code lamin login} will not be run"
    ))
  }

  # Set the default environment if not set
  reticulate::use_virtualenv("r-lamindb", required = FALSE)
  if (!reticulate::py_available()) {
    # Force reticulate to connect to Python
    py_config <- reticulate::py_config() # nolint object_usage_linter
  }

  if (!is.null(user)) {
    system2("lamin", paste("login", user))
  } else if (is.null(api_key)) {
    withr::with_envvar(c("LAMIN_API_KEY" = api_key), {
      system2("lamin", "login")
    })
  } else {
    if (Sys.getenv("LAMIN_API_KEY") == "") {
      cli::cli_abort("{.arg LAMIN_API_KEY} is not set")
    }

    system2("lamin", "login")
  }
}
