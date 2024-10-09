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
        "schema_str",
        "schema_id",
        "git_repo",
        "keep_artifacts_local",
        "api_url"
      )
      optional_columns <- c(
        "lnid", # api
        "lamindb_version", # api
        "storage", # api
        "storage_root", # lamin-cli
        "storage_region", # lamin-cli
        "db", # lamin-cli
        "db_scheme", # api
        "db_host", # api
        "db_port", # api
        "db_database", # api
        "db_permissions", # api
        "db_user_name", # api
        "db_user_password", # api
        "lamindb_version" # api
      )
      missing_column <- setdiff(expected_columns, names(settings))
      if (length(missing_column) > 0) {
        cli_abort("Missing column: ", missing_column)
      }
      unexpected_columns <- setdiff(names(settings), c(expected_columns, optional_columns))
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
    }
  )
)
