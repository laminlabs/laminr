#' @title InstanceSettings
#'
#' @noRd
#'
#' @description
#' Settings for a LaminDB instance. These settings are retrieved from the
#' Lamin Hub API and are used to connect to the instance.
InstanceSettings <- R6::R6Class( # nolint object_name_linter
  "InstanceSettings",
  cloneable = FALSE,
  public = list(
    #' @param settings A named list of settings for the instance
    initialize = function(settings) {
      expected_columns <- c(
        "owner",
        "name",
        "id",
        "lnid",
        "schema_str",
        "schema_id",
        "git_repo",
        "keep_artifacts_local",
        "api_url",
        "lamindb_version",
        "storage",
        "db_scheme",
        "db_host",
        "db_port",
        "db_database",
        "db_permissions",
        "db_user_name",
        "db_user_password"
      )
      missing_column <- setdiff(expected_columns, names(settings))
      if (length(missing_column) > 0) {
        cli_abort("Missing column: ", missing_column)
      }
      unexpected_columns <- setdiff(names(settings), expected_columns)
      if (length(unexpected_columns) > 0) {
        cli_abort("Unexpected column: ", unexpected_columns)
      }
      private$.settings <- settings
    }
  ),
  private = list(
    .settings = NULL
  ),
  active = list(
    #' Get the owner of the instance.
    owner = function() {
      private$.settings$owner
    },
    #' Get the name of the instance.
    name = function() {
      private$.settings$name
    },
    #' Get the ID of the instance.
    id = function() {
      private$.settings$id
    },
    #' Get the LNID of the instance.
    lnid = function() {
      private$.settings$lnid
    },
    #' Get the schema string of the instance.
    schema_str = function() {
      private$.settings$schema_str
    },
    #' Get the schema ID of the instance.
    schema_id = function() {
      private$.settings$schema_id
    },
    #' Get the git repo of the instance.
    git_repo = function() {
      private$.settings$git_repo
    },
    #' Get whether to keep artifacts local.
    keep_artifacts_local = function() {
      private$.settings$keep_artifacts_local
    },
    #' Get the API URL of the instance.
    api_url = function() {
      private$.settings$api_url
    },
    #' Get the LaminDB version of the instance.
    lamindb_version = function() {
      private$.settings$lamindb_version
    },
    #' Get the storage of the instance.
    storage = function() {
      private$.settings$storage
    },
    #' Get the database scheme of the instance.
    db_scheme = function() {
      private$.settings$db_scheme
    },
    #' Get the database host of the instance.
    db_host = function() {
      private$.settings$db_host
    },
    #' Get the database port of the instance.
    db_port = function() {
      private$.settings$db_port
    },
    #' Get the database of the instance.
    db_database = function() {
      private$.settings$db_database
    },
    #' Get the database permissions of the instance.
    db_permissions = function() {
      private$.settings$db_permissions
    },
    #' Get the database user name of the instance.
    db_user_name = function() {
      private$.settings$db_user_name
    },
    #' Get the database user password of the instance.
    db_user_password = function() {
      private$.settings$db_user_password
    }
  )
)
