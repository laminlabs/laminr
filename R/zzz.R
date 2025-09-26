.onLoad <- function(libname, pkgname) {
  require_lamindb(silent = TRUE)
  disable_lamin_colors()
}
