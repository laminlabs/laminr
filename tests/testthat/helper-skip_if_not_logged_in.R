skip_if_not_logged_in <- function() {
  user_settings <- .get_user_settings()
  testthat::skip_if(
    is.null(user_settings$access_token),
    "You must be logged in to run this test"
  )
}
