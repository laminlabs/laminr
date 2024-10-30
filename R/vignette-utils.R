# nolint start nolint_cyclomatic_linter
generate_module_markdown <- function(db, module_name, allowed_related_modules = c("core", module_name)) {
  # nolint end nolint_cyclomatic_linter
  module <- db$get_module(module_name)

  registry_names <- module$get_registry_names()

  type_map <- c(
    "BigAutoField" = "integer64",
    "AutoField" = "integer",
    "CharField" = "character",
    "BooleanField" = "logical",
    "DateTimeField" = "POSIXct",
    "TextField" = "character",
    "ForeignKey" = "integer64",
    "BigIntegerField" = "integer64",
    "SmallIntegerField" = "integer",
    "JSONField" = "list"
  )

  output <- c()

  for (registry_name in registry_names) { # nolint cyclocomp_linter
    registry <- module$get_registry(registry_name)
    fields <- registry$get_fields()

    if (registry$is_link_table) {
      next
    }

    output <- output |> c(paste0("## ", registry$class_name, "\n\n"))

    classes <- class(registry) |> discard(~ .x == "R6")
    class_urls <- paste0("`?", classes, "`")

    output <- output |> c(paste0("Base classes: ", paste(class_urls, collapse = ", "), "\n\n"))

    ## Document simple fields
    simple_fields <- fields |> keep(
      ~ is.null(.x$related_field_name) &&
        !grepl("^_", .x$field_name)
    )

    if (length(simple_fields) > 0) {
      output <- output |> c(paste0("### Simple fields\n\n"))
    }

    for (field in simple_fields) {
      field_type <-
        if (field$type %in% names(type_map)) {
          type_map[[field$type]]
        } else {
          field$type
        }
      output <- output |> c(paste0("* `", field$field_name, "` (`", field_type, "`)\n"))
    }

    if (length(simple_fields) > 0) {
      output <- output |> c("\n\n")
    }

    ## Document relational fields
    relational_fields <- fields |> keep(
      ~ !is.null(.x$related_field_name) &&
        !grepl("^_", .x$field_name) &&
        !.x$is_link_table &&
        .x$related_module_name == "core"
    )

    if (length(relational_fields) > 0) {
      output <- output |> c(paste0("### Relational fields\n\n"))
    }

    for (field in relational_fields) {
      related_module <- db$get_module(field$related_module_name)
      related_registry <- related_module$get_registry(field$related_registry_name)
      output <- output |> c(paste0(
        " * `", field$field_name, "` ([`", related_registry$class_name, "`](module_",
        related_module$name, ".html#", related_registry$name, "))\n"
      ))
    }

    if (length(relational_fields) > 0) {
      output <- output |> c("\n\n")
    }
  }

  output
}