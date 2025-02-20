#' Prompt yes/no
#'
#' Prompt the user for a yes or no response
#'
#' @param msg The prompt message to use. The string " (y/n)" is appended. Can
#'   contain **{cli}** inline markup.
#'
#' @returns `TRUE` or `FALSE` depending on the user response
#' @noRd
prompt_yes_no <- function(msg) {
  prompt_msg <- paste0(msg, " (y/n)")

  cli::cli_inform(prompt_msg, .envir = parent.frame())

  if (interactive()) {
    response <- readline("?: ")
  } else {
    response <- readLines("stdin", n = 1)
  }

  response <- tolower(trimws(response))

  if (response %in% c("y", "n")) {
    yes_no <- ifelse(response == "y", TRUE, FALSE)
  } else {
    cli::cli_alert_danger("Please enter 'y' or 'n'")
    yes_no <- prompt_yes_no(msg)
  }

  yes_no
}

#' Get message function
#'
#' Get the appropriate message function for a particular type of alert
#'
#' @param alert The type of alert to get the message function for
#'
#' @returns The matching message function
#' @noRd
get_message_fun <- function(alert = c("error", "warning", "message", "none")) {
  alert <- match.arg(alert)

  switch(alert,
         error = cli::cli_abort,
         warning = cli::cli_warn,
         message = cli::cli_inform,
         none = NULL
  )
}
