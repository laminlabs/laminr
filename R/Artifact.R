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
    #' Load the artifact into memory
    #'
    #' @description
    #' This currently only supports AnnData artifacts.
    #'
    #' @return The artifact
    load = function() {
      artifact_accessor <- private$get_value("_accessor")

      file_path <- self$cache()

      if (artifact_accessor == "AnnData") {
        requireNamespace("anndata", quietly = TRUE)
        anndata::read_h5ad(file_path)
      } else {
        cli_abort(paste0("Unsupported accessor: ", artifact_accessor))
      }
    },
    #' Cache the artifact to the local filesystem
    #'
    #' @description
    #' This currently only supports S3 storage.
    #'
    #' @return The path to the cached artifact
    cache = function() {
      # assume that an artifact will have a storage field,
      # and that the storage field will have a type field
      artifact_storage <- private$get_value("storage")
      artifact_key <- private$get_value("key")

      if (artifact_storage$type == "s3") {
        requireNamespace("s3", quietly = TRUE)
        root_dir <- file.path(Sys.getenv("HOME"), ".cache", "lamindb")
        s3::s3_get(
          paste0(artifact_storage$root, "/", artifact_key),
          region = artifact_storage$region,
          data_dir = root_dir
        )
      } else {
        cli_abort(paste0("Unsupported storage type: ", artifact_storage$type))
      }
    },
    describe = function(style = TRUE) {
      provenance_fields <- c(
        storage = "root",
        transform = "name",
        run = "started_at",
        created_by = "handle",
        test = "fail"
      )

      output_strings <- character()

      provenance_strings <- purrr::map_chr(
        names(provenance_fields),
        function(.field) {
          field_name <- try(self[[.field]][[provenance_fields[.field]]])
          if (inherits(field_name, "try-error") || is.null(field_name)) {
            return(NA_character_)
          }

          if (is.character(field_name)) {
            field_name <- paste0("'", field_name, "'")
          }

          paste0(
            cli::col_blue("    $", .field),
            cli::col_br_blue(" = "),
            cli::col_yellow(field_name)
          )
        }
      ) |>
        purrr::discard(is.na)

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
