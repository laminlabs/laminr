.onLoad <- function(libname, pkgname) {
  check_on_jupyter(
    alert = "warning",
    info = c(
      "!" = "Jupyter does not display Python output from {.pkg reticulate}, messages from Python will be lost",
      "i" = "See {.url https://github.com/laminlabs/laminr/issues/243} for details"
    )
  )

  require_lamindb(silent = TRUE)
}
