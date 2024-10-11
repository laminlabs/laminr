#' @title Field
#'
#' @noRd
#'
#' @description
#' A field in a registry.
Field <- R6::R6Class( # nolint object_name_linter
  "Field",
  cloneable = FALSE,
  public = list(
    #' @param type The type of the field. Can be one of:
    #'   "IntegerField", "JSONField", "OneToOneField", "SmallIntegerField",
    #'   "BigIntegerField", "AutoField", "BigAutoField", "BooleanField", "TextField",
    #'   "DateTimeField", "ManyToManyField", "CharField", "ForeignKey"
    #' @param through If the relation type is one-to-many, many-to-one, or many-to-many,
    #'   This value will be a named list with keys 'left_key', 'right_key', 'link_table_name'.
    #' @param field_name The name of the field in the registry. Example: `"name"`.
    #' @param registry_name The name of the registry. Example: `"user"`.
    #' @param column_name The name of the column in the database. Example: `"name"`.
    #' @param module_name The name of the module. Example: `"core"`.
    #' @param is_link_table Whether the field is a link table.
    #' @param relation_type The type of relation. Can be NULL or one of: "one-to-one", "many-to-one", "many-to-many".
    #' @param related_field_name The name of the related field in the related registry. Example: `"name"`.
    #' @param related_registry_name The name of the related registry. Example: `"user"`.
    #' @param related_module_name The name of the related module. Example: `"core"`.
    initialize = function(type,
                          through,
                          field_name,
                          registry_name,
                          column_name,
                          module_name,
                          is_link_table,
                          relation_type,
                          related_field_name,
                          related_registry_name,
                          related_module_name) {
      private$.type <- type
      private$.through <- through
      private$.field_name <- field_name
      private$.registry_name <- registry_name
      private$.column_name <- column_name
      private$.module_name <- module_name
      private$.is_link_table <- is_link_table
      private$.relation_type <- relation_type
      private$.related_field_name <- related_field_name
      private$.related_registry_name <- related_registry_name
      private$.related_module_name <- related_module_name
    },
    #' @description
    #' Print a `Field`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    print = function(style = TRUE) {
      cli::cat_line(self$to_string(style))
    },
    #' @description
    #' Create a string representation of a `Field`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      field_strings <- make_key_value_strings(
        self,
        c(
          "field_name",
          "column_name",
          "type",
          "registry_name",
          "module_name",
          "through",
          "is_link_table",
          "relation_type",
          "related_field_name",
          "related_registry_name",
          "related_module_name"
        )
      )

      make_class_string("Field", field_strings, style = style)
    }
  ),
  private = list(
    .type = NULL,
    .through = NULL,
    .field_name = NULL,
    .registry_name = NULL,
    .column_name = NULL,
    .module_name = NULL,
    .is_link_table = NULL,
    .relation_type = NULL,
    .related_field_name = NULL,
    .related_registry_name = NULL,
    .related_module_name = NULL
  ),
  active = list(
    #' @return The type of the field.
    type = function() {
      private$.type
    },
    #' @return The through value of the field.
    through = function() {
      private$.through
    },
    #' @return The field name.
    field_name = function() {
      private$.field_name
    },
    #' @return The registry name.
    registry_name = function() {
      private$.registry_name
    },
    #' @return The column name.
    column_name = function() {
      private$.column_name
    },
    #' @return The module name.
    module_name = function() {
      private$.module_name
    },
    #' @return Whether the field is a link table.
    is_link_table = function() {
      private$.is_link_table
    },
    #' @return The relation type.
    relation_type = function() {
      private$.relation_type
    },
    #' @return The related field name.
    related_field_name = function() {
      private$.related_field_name
    },
    #' @return The related registry name.
    related_registry_name = function() {
      private$.related_registry_name
    },
    #' @return The related module name.
    related_module_name = function() {
      private$.related_module_name
    }
  )
)
