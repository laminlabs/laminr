#' Lamin CLI functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Lamin CLI calls are available from R by importing the **lamin_cli** Python
#' module using `lc <- import_module("lamin_cli")`. The previous CLI functions
#' are now deprecated, see examples for how to switch to the new syntax.
#'
#' @usage
#' # Import the module instead of using deprecated functions
#' # lc <- import_module("lamin_cli")
#'
#' # Deprecated functions
#'
#' @name lamin_cli
#'
#' @examples
#' \dontrun{
#' # Import Lamin modules
#' lc <- import_module("lamin_cli")
#' ln <- import_module("lamindb")
#'
#' # Examples of replacing CLI functions with the lamin_cli module
#' }
NULL

#' @param instance Either a slug giving the instance to connect to
#' (`<owner>/<name>`) or an instance URL (`https://lamin.ai/owner/name`). For
#' `lamin_delete()`, the slug for the instance to delete.
#'
#' @details
#'
#' ## `lamin_connect()`
#'
#' Running this will set the LaminDB auto-connect option to `True` so you
#' auto-connect to `instance` when importing Python `lamindb`.
#' @export
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Connect to a LaminDB instance
#' lamin_connect(instance)
#' # ->
#' lc$connect(instance)
#' }
lamin_connect <- function(instance) {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_connect()",
    details = "Please use `lc <- import_module(\"lamin_cli\"); lc$connect()` instead."
  )

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

    system2("lamin", paste("connect", instance), stdout = TRUE, stderr = TRUE)
  }

  callr::r(
    system_fun,
    args = list(instance = instance),
    package = "laminr"
  ) |>
    print_stdout()
}

#' @export
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Disconnect from a LaminDB instance
#' lamin_disconnect()
#' # ->
#' lc$disconnect()
#' }
lamin_disconnect <- function() {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_disconnect()",
    details = "Please use `lc <- import_module(\"lamin_cli\"); lc$disconnect()` instead."
  )

  system_fun <- function() {
    require_lamindb(silent = TRUE)
    py_config <- reticulate::py_config() # nolint object_usage_linter

    system2("lamin", "disconnect", stdout = TRUE, stderr = TRUE)
  }

  callr::r(system_fun, package = "laminr") |> print_stdout()

  set_default_instance(NULL)
}

#' @param user Handle for the user to login as
#' @param api_key API key for a user
#'
#' @details
#'
#' ## `lamin_login()`
#'
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
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Log in as a LaminDB user
#' lamin_login(...)
#' # ->
#' lc$login(...)
#' }
lamin_login <- function(user = NULL, api_key = NULL) {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_login()",
    details = "Plese use `lc <- import_module(\"lamin_cli\"); lc$login()` instead."
  )

  check_default_instance()

  system_fun <- function(user, api_key) {
    require_lamindb(silent = TRUE)
    ln <- reticulate::import("lamindb")
    handle <- ln$setup$settings$user$handle

    if (!is.null(user)) {
      # If user is provided run `lamin login <user>`
      cli::cli_alert_info("Using provided user {.val {user}}")
      system2("lamin", paste("login", user), stdout = TRUE, stderr = TRUE)
    } else if (!is.null(api_key)) {
      # If api_key is provided, run `lamin login` with the LAMIN_API_KEY env var
      cli::cli_alert_info("Using provided API key")
      withr::with_envvar(c("LAMIN_API_KEY" = api_key), {
        system2("lamin", "login", stdout = TRUE, stderr = TRUE)
      })
    } else if (!is.null(handle) && handle != "anonymous") {
      # If there is a stored user handle run `lamin login <handle>`
      cli::cli_alert_info("Using stored user handle {.val {handle}}")
      system2("lamin", paste("login", handle), stdout = TRUE, stderr = TRUE)
    } else if (Sys.getenv("LAMIN_API_KEY") != "") {
      # If the LAMIN_API_KEY env var is already set run `lamin login`
      cli::cli_alert_info("Using {.field LAMIN_API_KEY} environment variable")
      system2("lamin", "login", stdout = TRUE, stderr = TRUE)
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
    package = "laminr"
  ) |>
    print_stdout()
}

#' @export
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Log out of LaminDB
#' lamin_logout()
#' # ->
#' lc$logout()
#' }
lamin_logout <- function() {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_logout()",
    details = "Please use lc <- import_module(\"lamin_cli\"); lc$logout() instead."
  )

  check_default_instance()

  system_fun <- function() {
    require_lamindb(silent = TRUE)
    py_config <- reticulate::py_config() # nolint object_usage_linter

    system2("lamin", "logout", stdout = TRUE, stderr = TRUE)
  }

  callr::r(system_fun, package = "laminr") |> print_stdout()
}

#' @param storage A local directory, AWS S3 bucket or Google Cloud Storage bucket
#' @param name A name for the instance
#' @param db A Postgres database connection URL, use `NULL` for SQLite
#' @param modules A vector of modules to include (e.g. "bionty")
#'
#' @export
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Create a new LaminDB instance
#' lamin_init(...)
#' # ->
#' lc$init(...)
#' }
lamin_init <- function(storage, name = NULL, db = NULL, modules = NULL) {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_init()",
    details = "Please use `lc <- import_module(\"lamin_cli\"); lc$init()` instead."
  )

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

    system2("lamin", args, stdout = TRUE, stderr = TRUE)
  }

  callr::r(
    system_fun,
    args = list(storage = storage, name = name, db = db, modules = modules),
    package = "laminr"
  ) |>
    print_stdout()
}

#' @param add_timestamp Whether to append a timestamp to `name` to make it unique
#' @param envir An environment passed to [withr::defer()]
#'
#' @details
#'
#' ## `lamin_init_temp()`
#'
#' For [lamin_init_temp()], a time stamp is appended to `name` (if
#' `add_timestamp = TRUE`) and then a new instance is initialised with
#' [lamin_init()] using a temporary directory. A [lamin_delete()] call is
#' registered as an exit handler with [withr::defer()] to clean up the instance
#' when `envir` finishes.
#'
#' The [lamin_init_temp()] function is mostly for internal use and in most cases
#' users will want [lamin_init()].
#'
#' @export
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Create a temporary LaminDB instance
#' lamin_init_temp(...)
#' # ->
#' create_temporary_instance()
#' }
lamin_init_temp <- function(name = "laminr-temp", db = NULL, modules = NULL,
                            add_timestamp = TRUE, envir = parent.frame()) {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_init_temp()",
    "use_temporary_instance()"
  )

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

#' @param force Whether to force deletion without asking for confirmation
#'
#' @export
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Delete a LaminDB entity
#' lamin_delete(...)
#' # ->
#' lc$delete(...)
#' }
lamin_delete <- function(instance, force = FALSE) {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_delete()",
    details = "Please use `lc <- import_module(\"lamin_cli\"); lc$delete()` instead."
  )

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
    system2("lamin", paste("delete --force", slug), stdout = TRUE, stderr = TRUE)
  }

  callr::r(
    system_fun,
    args = list(instance = instance),
    package = "laminr"
  ) |>
    print_stdout()
}

#' @param filepath Path to the file or folder to save
#' @param key The key for the saved item
#' @param description The description for the saved item
#' @param registry The registry for the saved item
#'
#' @export
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Save to a LaminDB instance
#' lamin_save(...)
#' # ->
#' lc$save(...)
#' }
lamin_save <- function(filepath, key = NULL, description = NULL, registry = NULL) {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_save()",
    details = "Please use `lc <- import_module(\"lamin_cli\"); lc$save()` instead."
  )

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

    system2("lamin", system_args, stdout = TRUE, stderr = TRUE)
  }

  callr::r(
    system_fun,
    args = list(system_args = args),
    package = "laminr"
  ) |>
    print_stdout()
}

#' @export
#' @rdname lamin_cli
#'
#' @examples
#' \dontrun{
#' # Access Lamin settings
#' lamin_settings()
#' # ->
#' ln$setup$settings
#' # OR
#' ln$settings
#' # Alternatively
#' get_current_lamin_settings()
#' }
lamin_settings <- function() {
  lifecycle::deprecate_warn(
    "1.2.0",
    "lamin_settings()",
    details = c(
      paste(
        "Please use `ln <- import_module(\"lamindb\");",
        "ln$setup$settings` OR `ln$settings` instead."
      ),
      "Alternatively, use `get_current_lamin_settings()`"
    )
  )

  system_fun <- function() {
    require_lamindb(silent = TRUE)
    py_config <- reticulate::py_config() # nolint object_usage_linter

    system2("lamin", "settings", stdout = TRUE, stderr = TRUE)
  }

  callr::r(system_fun, package = "laminr") |> print_stdout()
}
