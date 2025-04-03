#' Get loaded packages
#'
#' Get the currently loaded packages
#'
#' @returns A vector of the currently loaded package namespaces
#' @noRd
get_loaded_packages <- function() {
  setdiff(loadedNamespaces(), "base")
}

#' Get package repositories
#'
#' Get source repositories associated with packages (excluding CRAN and
#' Bioconductor)
#'
#' @param packages A vector of packages to get repositories for
#'
#' @returns A vector of source repositories
#' @noRd
get_package_repositories <- function(packages) {
  repos <- purrr::map_chr(packages, \(.pkg) {
    repo <- utils::packageDescription(.pkg)$Repository
    if (is.null(repo)) {
      NA_character_
    } else {
      repo
    }
  })

  repos[repos != "CRAN" & !startsWith(repos, "Bioconductor")] |>
    na.omit() |>
    unique() |>
    sort()
}
