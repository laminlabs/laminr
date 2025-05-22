#' laminr situation report
#'
#' Overview of the current status of the laminr package and its dependencies.
#' Can be useful for debugging.
#'
#' @returns Prints details of the current laminr status
#' @export
#'
#' @details
#' Provides information that can be useful for debugging. To run the function
#' when an error occurs set `options(error = laminr::laminr_sitrep)`. Note that
#' this should be used with some caution as it will print the status whenever
#' any error occurs.
#'
#' @examples
#' laminr_sitrep()
laminr_sitrep <- function() {
  default_instance <- get_default_instance()

  if (!is.null(default_instance)) {
    user <- get_current_lamin_user()
    instance <- suppressMessages(get_current_lamin_instance())
  }

  py_available <- reticulate::py_available()

  if (py_available) {
    py_modules <- c("lamindb", "bionty", "wetlab", "clinicore", "cellregistry", "omop")
    py_versions <- purrr::map_chr(
      py_modules,
      function(.module) {
        module_available <- reticulate::py_module_available(.module)
        if (module_available) {
          py_to_r(reticulate::py_get_attr(reticulate::import(.module), "__version__"))
        } else {
          ""
        }
      }
    ) |>
      rlang::set_names(py_modules)

    modules_bullets <- ifelse(
      py_versions == "",
      paste0("{.pkg ", names(py_versions), "}"),
      paste0("{.pkg ", names(py_versions), "} v", py_versions)
    ) |>
      rlang::set_names(ifelse(py_versions == "", "x", "v"))
  }

  cli::cli_h1("{.pkg laminr} status")
  cli::cli_text("{.field Version}: {.val {packageVersion('laminr')}}")

  if (!is.null(default_instance)) {
    cli::cli_text("{.field User}: {.val {user}}")
    cli::cli_text("{.field Instance}: {.val {instance}}")
  } else {
    cli::cli_alert_danger("Not currently connected to an instance")
  }

  if (py_available) {
    cli::cli_h2("Python {.pkg {reticulate::py_config()$version_string}}")
    cli::cli_bullets(modules_bullets)
  } else {
    cli::cli_alert_danger("Python not available")
  }
}
