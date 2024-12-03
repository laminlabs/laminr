#' @title ArtifactRecord
#'
#' @noRd
#'
#' @description
#' A record that represents an artifact.
ArtifactRecord <- R6::R6Class( # nolint object_name_linter
  "ArtifactRecord",
  inherit = Record,
  public = list(
    #' @description
    #' Load the artifact into memory.
    #'
    #' @param ... Additional arguments to pass to the loader
    #'
    #' @return The artifact
    load = function(...) {
      file_path <- self$cache()

      suffix <- private$get_value("suffix")

      load_file(file_path, suffix, ...)
    },
    #' @description
    #' Cache the artifact to the local filesystem. When the Python `lamindb`
    #' package is not available this only supports S3 storage.
    #'
    #' @return The path to the cached artifact
    cache = function() {
      py_lamin <- private$.instance$get_py_lamin()
      if (!is.null(py_lamin)) {
        if (isTRUE(private$.instance$is_default)) {
          py_artifact <- py_lamin$Artifact$get(self$uid)
        } else {
          instance_settings <- private$.instance$get_settings()
          slug <- paste0(instance_settings$owner, "/", instance_settings$name)

          py_artifact <- py_lamin$Artifact$using(slug)$get(self$uid)
        }
        return(py_artifact$cache()$path)
      }

      cli::cli_warn(paste(
        "The Python {.pkg lamindb} package is not available.",
        "Loaded artifacts will not be tracked."
      ))

      # assume that an artifact will have a storage field,
      # and that the storage field will have a type field
      artifact_storage <- private$get_value("storage")
      artifact_key <- private$get_value("key")

      if (artifact_storage$type == "s3") {
        check_requires("Caching artifacts from s3", "s3")
        root_dir <- file.path(Sys.getenv("HOME"), ".cache", "lamindb")
        s3::s3_get(
          paste0(artifact_storage$root, "/", artifact_key),
          region = artifact_storage$region,
          progress = TRUE,
          data_dir = root_dir
        )
      } else {
        cli_abort(paste0("Unsupported storage type: ", artifact_storage$type))
      }
    },
    #' @description
    #' Return a backed data object. Currently only supports TileDB-SOMA
    #' artifacts.
    #'
    #' @return A [tiledbsoma::SOMACollection] or [tiledbsoma::SOMAExperiment]
    #' object
    open = function() {
      is_tiledbsoma <- private$get_value("suffix") == ".tiledbsoma" ||
        private$get_value("_accessor") == "tiledbsoma"

      if (!is_tiledbsoma) {
        cli::cli_abort(
          "The {.code open} method is only supported for TileDB-SOMA artifacts"
        )
      }

      check_requires(
        "Opening TileDB-SOMA artifacts", "tiledbsoma",
        extra_repos = "https://chanzuckerberg.r-universe.dev"
      )

      artifact_uri <- paste0(
        private$get_value("storage")$root,
        "/",
        private$get_value("key")
      )

      tiledbsoma::SOMAOpen(artifact_uri)
    },
    #' @description
    #' Print a more detailed description of an `ArtifactRecord`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    describe = function(style = TRUE) {
      provenance_fields <- c(
        storage = "root",
        transform = "name",
        run = "started_at",
        created_by = "handle",
        test = "fail"
      )

      output_strings <- character()

      provenance_strings <- map_chr(
        names(provenance_fields),
        function(.field) {
          field_name <- try(self[[.field]][[provenance_fields[.field]]])
          if (inherits(field_name, "try-error") || is.null(field_name)) {
            return(NA_character_)
          }

          if (is.character(field_name)) {
            field_name <- paste0("'", field_name, "'")
          }

          paste0("    $", .field, " = ", field_name)
        }
      ) |>
        discard(is.na)

      if (length(provenance_strings) > 0) {
        output_strings <- c(
          output_strings,
          cli::style_italic(cli::col_br_magenta("  Provenance")),
          provenance_strings
        )
      }

      self$print(style)
      for (.line in output_strings) {
        if (isFALSE(style)) {
          .line <- cli::ansi_strip(.line)
        }

        cli::cat_line(.line)
      }
    }
  )
)
