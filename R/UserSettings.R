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
    #' @description
    #' Creates an instance of this R6 class. This class should not be instantiated directly,
    #' but rather by connecting to a LaminDB instance using the [connect()] function.
    #'
    #' @param settings A named list of settings for the user
    initialize = function(settings) {
      expected_keys <- c(
        "email",
        "password",
        "access_token",
        "api_key",
        "uid",
        "uuid",
        "handle",
        "name"
      )
      missing_column <- setdiff(expected_keys, names(settings))
      if (length(missing_column) > 0) {
        cli_abort("Missing column: ", missing_column)
      }
      unexpected_columns <- setdiff(names(settings), expected_keys)
      if (length(unexpected_columns) > 0) {
        cli_abort("Unexpected column: ", unexpected_columns)
      }
      private$.settings <- settings
    },
    #' @description
    #' Print a `UserSettings`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    print = function(style = TRUE) {
      cli::cat_line(self$to_string(style))
    },
    #' @description
    #' Create a string representation of a `UserSettings`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      field_strings <- make_key_value_strings(private$.settings)

      make_class_string("UserSettings", field_strings, style = style)
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
