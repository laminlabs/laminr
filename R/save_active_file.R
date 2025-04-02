find_active_file <- function(arg = file, call = parent.frame()) {
  if (!is_rstudio()) {
    cli_abort("Argument {.arg {arg}} is missing, with no default", call = call)
  }
  normalizePath(rstudioapi::getSourceEditorContext()$path)
}

save_active_file <- function(file = find_active_file()) {
  if (is_rstudio()) {
    if (rstudioapi::hasFun("documentSaveAll")) {
      rstudioapi::documentSaveAll()
    }
    rstudioapi::executeCommand("activateConsole", quiet = TRUE)
  }

  system2("lamin", c("save", file))
}
