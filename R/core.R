wrap_core <- function(py_lamindb_core) {
  wrap_python(
    py_lamindb_core,
    active = list(
      datasets = function(value) {
        if (missing(value)) {
          wrap_core_datasets(unwrap_python(self)$datasets)
        } else {
          cli::cli_abort("The {.field datasets} slot is read-only.")
        }
      }
    )
  )
}

wrap_core_datasets <- function(py_lamindb_core_datasets) {
  wrap_python(
    py_lamindb_core_datasets,
    public = list(
      small_dataset1 = wrap_with_py_arguments(
        core_datasets_small_dataset1,
        py_lamindb_core_datasets$small_dataset1
      )
    )
  )
}

core_datasets_small_dataset1 <- function(self, ...) {
  args <- list(...)

  py_object <- unwrap_python(self)
  unwrap_args_and_call(py_object$small_dataset1, args) |>
    standardise_list_columns()
}
