#' InstanceSettings class
#'
#' The InstanceSettings class is used to store the settings of a LaminDB instance.
#'
#' @importFrom R6 R6Class
#'
#' @noRd
InstanceSettings <- R6::R6Class( # nolint object_name_linter
  "InstanceSettings",
  cloneable = FALSE,
  public = list(
    #' Initialize the InstanceSettings class
    #'
    #' @param id The instance ID of the LaminDB instance.
    #' @param owner The owner of the LaminDB instance.
    #' @param name The name of the LaminDB instance.
    #' @param api_url The base URL of the LaminDB API.
    #' @param schema_id The schema ID of the LaminDB schema.
    initialize = function(
      owner,
      name,
      id,
      schema_str,
      schema_id,
      git_repo,
      keep_artifacts_local,
      api_url,
      lamindb_version,
      storage,
      db_scheme,
      db_host,
      db_port,
      db_database,
      db_permissions,
      db_user_name,
      db_user_password
    ) {
      private$.owner <- owner
      private$.name <- name
      private$.id <- id
      private$.schema_str <- schema_str
      private$.schema_id <- schema_id
      private$.git_repo <- git_repo
      private$.keep_artifacts_local <- keep_artifacts_local
      private$.api_url <- api_url
      private$.lamindb_version <- lamindb_version
      private$.storage <- storage
      private$.db_scheme <- db_scheme
      private$.db_host <- db_host
      private$.db_port <- db_port
      private$.db_database <- db_database
      private$.db_permissions <- db_permissions
      private$.db_user_name <- db_user_name
      private$.db_user_password <- db_user_password
    }
  ),
  private = list(
    .owner = NULL,
    .name = NULL,
    .id = NULL,
    .schema_str = NULL,
    .schema_id = NULL,
    .git_repo = NULL,
    .keep_artifacts_local = NULL,
    .api_url = NULL,
    .lamindb_version = NULL,
    .storage = NULL,
    .db_scheme = NULL,
    .db_host = NULL,
    .db_port = NULL,
    .db_database = NULL,
    .db_permissions = NULL,
    .db_user_name = NULL,
    .db_user_password = NULL
  ),
  active = list(
    owner = function() {
      private$.owner
    },
    name = function() {
      private$.name
    },
    id = function() {
      private$.id
    },
    schema_str = function() {
      private$.schema_str
    },
    schema_id = function() {
      private$.schema_id
    },
    git_repo = function() {
      private$.git_repo
    },
    keep_artifacts_local = function() {
      private$.keep_artifacts_local
    },
    api_url = function() {
      private$.api_url
    },
    lamindb_version = function() {
      private$.lamindb_version
    },
    storage = function() {
      private$.storage
    },
    db_scheme = function() {
      private$.db_scheme
    },
    db_host = function() {
      private$.db_host
    },
    db_port = function() {
      private$.db_port
    },
    db_database = function() {
      private$.db_database
    },
    db_permissions = function() {
      private$.db_permissions
    },
    db_user_name = function() {
      private$.db_user_name
    },
    db_user_password = function() {
      private$.db_user_password
    }
  )
)
