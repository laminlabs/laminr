.onLoad <- function(libname, pkgname) {
  reticulate::use_virtualenv("r-lamindb", required = FALSE)
}
