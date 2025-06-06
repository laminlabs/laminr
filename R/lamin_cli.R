#' Connect to a LaminDB instance
#'
#' Connect to a LaminDB instance by calling `lamin connect` on the command line
#'
#' @param instance Either a slug giving the instance to connect to
#' (`<owner>/<name>`) or an instance URL (`https://lamin.ai/owner/name`)
#'
#' @export
#'
#' @details
#' Running this will set the LaminDB auto-connect option to `True` so you
#' auto-connect to `instance` when importing Python `lamindb`.
#'
#' @examples
#' \dontrun{
#' lamin_connect("laminlabs/cellxgene")
#' }
lamin_connect <- function(instance) {
  if (is.null(instance)) {
    cli::cli_alert_danger(
      "{.arg instance} is {.val NULL}, {.code lamin connect} will not be run"
    )
    return(invisible(NULL))
  }

  check <- check_default_instance(instance)

  if (isTRUE(check)) {
    cli::cli_alert("Already connected to {.val {instance}}")
    return(invisible(NULL))
  }

  system_fun <- function(instance) {
    require_lamindb(silent = TRUE)
    py_config <- reticulate::py_config() # nolint object_usage_linter

    system2("lamin", paste("connect", instance))
  }

  callr::r(
    system_fun,
    args = list(instance = instance),
    show = TRUE,
    package = "laminr"
  ) |>
    invisible()
}

#' Disconnect from a LaminDB instance
#'
#' Disconnect from the current LaminDB instance by calling `lamin connect` on
#' the command line
#'
#' @export
#'
#' @examples
#' \dontrun{
#' lamin_disconnect()
#' }
lamin_disconnect <- function() {
  system_fun <- function() {
    require_lamindb(silent = TRUE)
    py_config <- reticulate::py_config() # nolint object_usage_linter

    system2("lamin", "disconnect")
  }

  callr::r(system_fun, show = TRUE, package = "laminr")

  set_default_instance(NULL)
}

#' Log into LaminDB
#'
#' Log in as a LaminDB user
#'
#' @param user Handle for the user to login as
#' @param api_key API key for a user
#'
#' @details
#' Depending on the input, one of these commands will be run (in this order):
#'
#' 1. If `user` is set then `lamin login <user>`
#' 2. Else if `api_key` is set then set the `LAMIN_API_KEY` environment variable
#' temporarily with `withr::with_envvar()` and run `lamin login`
#' 3. Else if there is a stored user handle run `lamin login <handle>`
#' 4. Else if the `LAMIN_API_KEY` environment variable is set run `lamin login`
#'
#' Otherwise, exit with an error
#'
#' @export
lamin_login <- function(user = NULL, api_key = NULL) {
  check_default_instance()

  system_fun <- function(user, api_key) {
    require_lamindb(silent = TRUE)
    ln <- reticulate::import("lamindb")
    handle <- ln$setup$settings$user$handle

    if (!is.null(user)) {
      # If user is provided run `lamin login <user>`
      cli::cli_alert_info("Using provided user {.val {user}}")
      system2("lamin", paste("login", user))
    } else if (!is.null(api_key)) {
      # If api_key is provided, run `lamin login` with the LAMIN_API_KEY env var
      cli::cli_alert_info("Using provided API key")
      withr::with_envvar(c("LAMIN_API_KEY" = api_key), {
        system2("lamin", "login")
      })
    } else if (!is.null(handle) && handle != "anonymous") {
      # If there is a stored user handle run `lamin login <handle>`
      cli::cli_alert_info("Using stored user handle {.val {handle}}")
      system2("lamin", paste("login", handle))
    } else if (Sys.getenv("LAMIN_API_KEY") != "") {
      # If the LAMIN_API_KEY env var is already set run `lamin login`
      cli::cli_alert_info("Using {.field LAMIN_API_KEY} environment variable")
      system2("lamin", "login")
    } else {
      # Fail to log in
      cli::cli_abort(
        "Unable to log in. Please provide {.arg user} or {.arg api_key}."
      )
    }
  }

  callr::r(
    system_fun,
    args = list(user = user, api_key = api_key),
    show = TRUE,
    package = "laminr"
  ) |>
    invisible()
}

#' Log out of LaminDB
#'
#' Log out of LaminDB
#'
#' @export
lamin_logout <- function() {
  check_default_instance()

  system_fun <- function() {
    require_lamindb(silent = TRUE)
    py_config <- reticulate::py_config() # nolint object_usage_linter

    system2("lamin", "logout")
  }

  callr::r(system_fun, show = TRUE, package = "laminr") |>
    invisible()
}

#' Initialise LaminDB
#'
#' Initialise a new LaminDB instance
#'
#' @param storage A local directory, AWS S3 bucket or Google Cloud Storage bucket
#' @param name A name for the instance
#' @param db A Postgres database connection URL, use `NULL` for SQLite.
#' @param modules A vector of modules to include (e.g. "bionty")
#'
#' @rdname lamin_init
#' @export
#'
#' @examples
#' \dontrun{
#' lamin_init("mydata", modules = c("bionty", "wetlab"))
#' }
lamin_init <- function(storage, name = NULL, db = NULL, modules = NULL) {
  system_fun <- function(storage, name, db, modules) {
    require_lamindb(silent = TRUE)

    if (!is.null(modules)) {
      for (module in modules) {
        require_module(module, silent = TRUE)
      }
    }
    py_config <- reticulate::py_config() # nolint object_usage_linter

    if (!is.null(modules)) {
      check_requires(
        "Initalising a database with these modules", modules,
        language = "Python"
      )
    }

    args <- paste("init --storage", storage)

    if (!is.null(name)) {
      args <- c(args, paste("--name", name))
    }

    if (!is.null(db)) {
      args <- c(args, paste("--db", name))
    }

    if (!is.null(modules)) {
      args <- c(
        args, paste("--modules", paste(modules, collapse = ","))
      )
    }

    system2("lamin", args)
  }

  callr::r(
    system_fun,
    args = list(storage = storage, name = name, db = db, modules = modules),
    show = TRUE,
    package = "laminr"
  ) |>
    invisible()
}

#' @param add_timestamp Whether to append a timestamp to `name` to make it unique
#' @param envir An environment passed to [withr::defer()]
#'
#' @details
#' For [lamin_init_temp()], a time stamp is appended to `name` (if
#' `add_timestamp = TRUE`) and then a new instance is initialised with
#' [lamin_init()] using a temporary directory. A [lamin_delete()] call is
#' registered as an exit handler with [withr::defer()] to clean up the instance
#' when `envir` finishes.
#'
#' The [lamin_init_temp()] function is mostly for internal use and in most cases
#' users will want [lamin_init()].
#'
#' @rdname lamin_init
#' @export
lamin_init_temp <- function(name = "laminr-temp", db = NULL, modules = NULL,
                            add_timestamp = TRUE, envir = parent.frame()) {
  if (isTRUE(add_timestamp)) {
    # Add a time stamp to get a unique name
    timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")
    name <- paste0(name, "-", timestamp)
  }

  # Create the temporary storage for this instance
  temp_storage <- file.path(tempdir(), name)

  # Initialise the temporary instance
  lamin_init(temp_storage, name = name, db = db, modules = modules)

  # Add the clean up handler to the environment
  withr::defer(lamin_delete(name, force = TRUE), envir = envir)
  withr::defer(unlink(temp_storage, recursive = TRUE, force = TRUE), envir = envir)
}

#' LaminDB delete
#'
#' Delete a LaminDB entity. Currently only supports instances.
#'
#' @param instance Identifier for the instance to delete (e.g. "owner/name")
#' @param force Whether to force deletion without asking for confirmation
#'
#' @export
#'
#' @examples
#' \dontrun{
#' lamin_init("to-delete")
#' lamin_delete("to-delete")
#' }
lamin_delete <- function(instance, force = FALSE) {
  # Python prompts don't work so need to prompt in R
  if (!isTRUE(force)) {
    confirm <- prompt_yes_no(
      "Are you sure you want to delete instance {.val {instance}}?"
    )
    if (isFALSE(confirm)) {
      cli::cli_alert_danger("Instance {.val {instance}} will not be deleted")
      return(invisible(NULL))
    }
  }

  system_fun <- function(instance) {
    require_lamindb(silent = TRUE)
    ln_setup <- reticulate::import("lamindb_setup")

    # Use lamindb_setup to resolve owner/name from instance
    owner_name <- ln_setup$`_connect_instance`$get_owner_name_from_identifier(instance)
    slug <- paste0(owner_name[[1]], "/", owner_name[[2]])

    # Always force here to avoid Python prompt
    system2("lamin", paste("delete --force", slug))
  }

  callr::r(
    system_fun,
    args = list(instance = instance),
    show = TRUE,
    package = "laminr"
  ) |>
    invisible()
}

#' Save to a LaminDB instance
#'
#' Save a file or folder to a LaminDB instance by calling `lamin save` on the
#' command line
#'
#' @param filepath Path to the file or folder to save
#' @param key The key for the saved item
#' @param description The description for the saved item
#' @param registry The registry for the saved item
#'
#' @export
#'
#' @details
#' See `lamin save --help` for details of what database entries are created for
#' different file types
#'
#' @examples
#' \dontrun{
#' my_file <- tempfile()
#' lamin_save(my_file)
#' }
lamin_save <- function(filepath, key = NULL, description = NULL, registry = NULL) {
  args <- "save"

  if (!is.null(key)) {
    args <- c(args, paste("--key", key))
  }

  if (!is.null(description)) {
    args <- c(args, paste("--description", description))
  }

  if (!is.null(registry)) {
    args <- c(
      args, paste("--registry", registry)
    )
  }

  args <- c(args, filepath)

  system_fun <- function(system_args) {
    require_lamindb(silent = TRUE)
    py_config <- reticulate::py_config() # nolint object_usage_linter

    system2("lamin", args)
  }

  callr::r(
    system_fun,
    args = list(system_args = args),
    show = TRUE,
    package = "laminr"
  ) |>
    invisible()
}

#' Lamin settings
#'
#' Get the current LaminDB settings by calling `lamin settings` on the command
#' line
#'
#' @returns A list of the current LaminDB settings
#' @export
#'
#' @examples
#' \dontrun{
#' lamin_settings()
#' }
lamin_settings <- function() {
  system_fun <- function() {
    require_lamindb(silent = TRUE)
    py_config <- reticulate::py_config() # nolint object_usage_linter

    system2("lamin", "settings", stdout = TRUE)
  }

  settings_vector <- callr::r(system_fun, show = TRUE, package = "laminr")

  settings <- list()
  current_parent <- NULL

  for (setting in settings_vector) {
    # Skip lines that aren't settings
    if (!grepl(":", setting)) {
      next
    }

    is_nested <- grepl("^- ", setting)

    parts <- strsplit(setting, ":", 2)[[1]]
    field <- trimws(parts[1])
    value <- trimws(parts[2])

    # Skip empty values
    if (value == "None" || value == "set()") {
      next
    }

    if (value == "True") {
      value <- TRUE
    }

    if (value == "False") {
      value <- FALSE
    }

    # Turn {'item1', 'item2'} into a vector
    if (grepl("\\{.*\\}", value)) {
      value <- gsub(".*\\{(.*?)\\}.*", "\\1", value)
      value <- strsplit(value, ",")[[1]]
      value <- trimws(value)
      value <- gsub("^['\"]|['\"]$", "", value)
    }

    if (is_nested) {
      field <- sub("^- ", "", field)
      settings[[current_parent]][[field]] <- value
    } else {
      current_parent <- field
      settings[[current_parent]] <- list(value = value)
    }
  }

  purrr::map(settings, function(.setting) {
    if (length(.setting) == 1) {
      .setting[[1]]
    } else {
      .setting
    }
  })
}
