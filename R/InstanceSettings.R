InstanceSettings <- R6::R6Class( # nolint object_name_linter
  "InstanceSettings",
  cloneable = FALSE,
  public = list(
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
    owner = function() {
      private$.settings$owner
    },
    name = function() {
      private$.settings$name
    },
    id = function() {
      private$.settings$id
    },
    lnid = function() {
      private$.settings$lnid
    },
    schema_str = function() {
      private$.settings$schema_str
    },
    schema_id = function() {
      private$.settings$schema_id
    },
    git_repo = function() {
      private$.settings$git_repo
    },
    keep_artifacts_local = function() {
      private$.settings$keep_artifacts_local
    },
    api_url = function() {
      private$.settings$api_url
    },
    lamindb_version = function() {
      private$.settings$lamindb_version
    },
    storage = function() {
      private$.settings$storage
    },
    db_scheme = function() {
      private$.settings$db_scheme
    },
    db_host = function() {
      private$.settings$db_host
    },
    db_port = function() {
      private$.settings$db_port
    },
    db_database = function() {
      private$.settings$db_database
    },
    db_permissions = function() {
      private$.settings$db_permissions
    },
    db_user_name = function() {
      private$.settings$db_user_name
    },
    db_user_password = function() {
      private$.settings$db_user_password
    }
  )
)
