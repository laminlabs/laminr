#' laminr status
#'
#' Overview of the current status of the laminr package and its dependencies.
#' Can be useful for debugging.
#'
#' @returns A `laminr_status` object
#' @export
#'
#' @details
#' Provides information that can be useful for debugging. To run the function
#' when an error occurs, set
#' `options(error = function() { print(laminr::laminr_status() })`. Note that
#' this should be used with some caution as it will print the status whenever
#' any error occurs.
#'
#' @examples
#' laminr_status()
laminr_status <- function() {
  status_list <- list(
    version = utils::packageVersion("laminr")
  )

  env_vars <- Sys.getenv(
    c(
      "LAMINR_LAMINDB_VERSION",
      "LAMINR_LAMINDB_OPTIONS"
    ),
    unset = NA
  )
  env_vars <- env_vars[!is.na(env_vars)]

  if (length(env_vars) > 0) {
    status_list$env_vars <- as.list(env_vars)
  }

  if (!is.null(get_default_instance())) {
    settings <- get_current_lamin_settings(minimal = TRUE)
    status_list$settings <- list(
      user = settings$user$handle,
      instance = settings$instance$slug
    )
  }

  if (reticulate::py_available()) {
    py_modules <- c(
      "lamindb",
      "lamin_cli",
      "lamin_utils",
      "lamindb_setup",
      "bionty",
      "wetlab",
      "clinicore",
      "cellregistry",
      "omop",
      "scipy",
      "numpy",
      "pandas"
    )

    py_available <- purrr::map_lgl(py_modules, reticulate::py_module_available)

    py_versions <- purrr::map2_chr(
      py_modules,
      py_available,
      function(.module, .available) {
        if (.available) {
          py_to_r(reticulate::py_get_attr(reticulate::import(.module), "__version__"))
        } else {
          NA_character_
        }
      }
    )

    status_list$python <- list(
      version = reticulate::py_config()$version_string,
      modules = data.frame(
        module = py_modules,
        available = py_available,
        version = py_versions
      )
    )
  }

  structure(status_list, class = c("laminr_status", "list"))
}

#' @export
format.laminr_status <- function(x, ...) {
  cli::cli_format_method({
    cli::cli_h1("{.pkg laminr} {.val {x$version}}")

    if (!is.null(x$env_vars)) {
      cli::cli_h2("Environment Variables")
      cli::cli_bullets(
        lapply(names(x$env_vars), function(var) {
          paste0("{.envvar ", var, "}: {.val ", x$env_vars[[var]], "}")
        })
      )
    }

    cli::cli_h2("Settings")
    if (!is.null(x$settings)) {
      cli::cli_text("{.field User}: {.val {x$settings$user}}")
      cli::cli_text("{.field Instance}: {.val {x$settings$instance}}")
      cli::cli_text()
      cli::cli_bullets(c(
        "i" = paste(
          "To change the instance, use",
          "{.code lc <- import_module(\"lamin_cli\"); lc$connect()}"
        ),
        "i" = paste(
          "Run {.run get_current_lamin_settings()}",
          "to see the full settings information"
        )
      ))
    } else {
      cli::cli_alert_danger("Not connected to an instance")
    }

    if (!is.null(x$python)) {
      cli::cli_h2("Python {.pkg {reticulate::py_config()$version_string}}")

      modules <- x$python$modules
      ifelse(
        modules$available,
        paste0("{.pkg ", modules$module, "} v", modules$version),
        paste0("{.pkg ", modules$module, "}")
      ) |>
        rlang::set_names(ifelse(modules$available, "v", "x")) |>
        cli::cli_bullets()

      cli::cli_text()
      cli::cli_bullets(c(
        "i" = "Run {.run reticulate::py_config()} and {.run reticulate::py_require()} for more information"
      ))
    } else {
      cli::cli_h2("Python")
      cli::cli_alert_danger("Python not available")
    }
  })
}

#' @export
print.laminr_status <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
}
