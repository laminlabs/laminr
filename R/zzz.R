.onLoad <- function(libname, pkgname) {
  check_on_jupyter(alert = "warning")

  require_lamindb(silent = TRUE)
}
