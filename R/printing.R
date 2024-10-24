#' Make key value strings
#'
#' Generate a vector of styled strings representing key-value pairs. Any
#' `NULL`/`NA` values are not returned.
#'
#' @param mapping Any object for which values can be retrieved using names with
#'   `mapping[[name]]`
#' @param names Vector of names to create strings for. Defaults to all names of
#'   `mapping`
#' @param quote_strings Logical, whether to quote string values
#'
#' @return A vector of `cli::cli_ansi_string` objects
#' @noRd
make_key_value_strings <- function(mapping, names = NULL, quote_strings = TRUE) {
  if (is.null(names)) {
    names <- names(mapping)
  }

  purrr::map_chr(names, function(.name) {
    value <- mapping[[.name]]

    if (is.null(value)) {
      return(NA_character_)
    }

    if (quote_strings && is.character(value)) {
      value <- paste0("'", value, "'")
    }

    if (is.list(value)) {
      list_strings <- make_key_value_strings(value)
      value <- paste0(
        "list(", cli::ansi_strip(paste(list_strings, collapse = ", ")), ")"
      )
    }

    paste0(
      cli::col_blue(.name), cli::col_br_blue("="), cli::col_yellow(value)
    )
  }) |>
    purrr::discard(is.na)
}

#' Make a string representation of a class
#'
#' @param class_name Name of the class
#' @param field_strings A vector of formatted name strings as produced by
#'   `make_key_value_strings`
#' @param style Whether or not to returned a styled string
#'
#' @return A `cli::cli_ansi_string` object if `style = TRUE`, otherwise a
#'   character vector
#' @noRd
make_class_string <- function(class_name, field_strings, style = TRUE) {
  string <- paste0(
    cli::style_bold(cli::col_br_green(class_name)), "(",
    paste(field_strings, collapse = ", "),
    ")"
  )

  if (isFALSE(style)) {
    string <- cli::ansi_strip(string)
  }

  return(string)
}
