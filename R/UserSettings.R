#' @title UserSettings
#'
#' @noRd
#'
#' @description
#' Settings for a Lamin user. These settings are retrieved from the
#' Lamin Hub API and are used to connect to the user.
UserSettings <- R6::R6Class( # nolint object_name_linter
  "UserSettings",
  cloneable = FALSE,
  public = list(
    #' @param settings A named list of settings for the user
    initialize = function(settings) {
      expected_columns <- c(
        "email",
        "password",
        "access_token",
        "api_key",
        "uid",
        "uuid",
        "handle",
        "name"
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
    # Get the email of the user.
    email = function() {
      private$.settings$email
    },
    # Get the password of the user.
    password = function() {
      private$.settings$password
    },
    # Get the access token of the user.
    access_token = function() {
      private$.settings$access_token
    },
    # Get the API key of the user.
    api_key = function() {
      private$.settings$api_key
    },
    # Get the UID of the user.
    uid = function() {
      private$.settings$uid
    },
    # Get the UUID of the user.
    uuid = function() {
      private$.settings$uuid
    },
    # Get the handle of the user.
    handle = function() {
      private$.settings$handle
    },
    # Get the name of the user.
    name = function() {
      private$.settings$name
    }
  )
)
