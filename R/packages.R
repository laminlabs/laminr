#' Get R environment
#'
#' Get the current R environment to save when finishing a tracking run
#'
#' @returns A vector with package strings
#' @noRd
get_r_environment <- function() {
  pkg_info <- sessioninfo::package_info(include_base = TRUE)

  pkgs_df <- data.frame(
    package = pkg_info$package,
    version = pkg_info$loadedversion,
    repo = get_package_sources(pkg_info$package)
  )

  paste0(pkgs_df$package, "==", pkgs_df$version, " @ ", pkgs_df$repo)
}

#' Get package sources
#'
#' Get sources for a set of packages. This is similar to what is returned by
#' `sessioninfo::package_info()` not truncated (see
#' https://github.com/r-lib/sessioninfo/issues/116)
#'
#' @param packages Vector of package names to get sources for
#' @noRd
get_package_sources <- function(packages) {
  purrr::map_chr(packages, purrr::possibly(\(.pkg) {
    desc <- utils::packageDescription(.pkg)
    if (!is.null(desc$Repository)) {
      return(desc$Repository)
    }

    if (!is.null(desc$Priority) && desc$Priority == "base") {
      return("base")
    }

    if (!is.null(desc$biocViews)) {
      if (!is.null(desc$RemoteRepos)) {
        bioc_version <- sub(".*packages/(\\d+\\.\\d+).*", "\\1", desc$RemoteRepos)
      } else {
        bioc_version <- ""
      }

      if (grepl("AnnotationData", desc$biocViews)) {
        bioc_type <- "AnnotationData"
      } else {
        bioc_type <- ""
      }

      return(trimws(paste("Bioconductor", bioc_version, bioc_type)))
    }

    if (!is.null(desc$RemoteType)) {
      remote_source <- desc$RemoteType

      if (!is.null(desc$RemoteUsername) || !is.null(desc$RemoteRepo) || !is.null(desc$RemoteSha)) {
        remote_source <- paste0(remote_source, " (")
        if (!is.null(desc$RemoteUsername)) {
          remote_source <- paste0(remote_source, desc$RemoteUsername)
        }
        if (!is.null(desc$RemoteRepo)) {
          if (!is.null(desc$RemoteUsername)) {
            remote_source <- paste0(remote_source, "/")
          }
          remote_source <- paste0(remote_source, desc$RemoteRepo)
        }
        if (!is.null(desc$RemoteSha)) {
          remote_source <- paste0(remote_source, "@", desc$RemoteSha)
        }
        remote_source <- paste0(remote_source, ")")
      }

      return(remote_source)
    }

    if (pkgload::is_dev_package(.pkg)) {
      return("pkgload")
    }

    return(NA_character_) # nolint: return_linter
  }, otherwise = "Unknown")) |>
    purrr::set_names(packages)
}
