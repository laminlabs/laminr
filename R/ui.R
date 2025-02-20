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
