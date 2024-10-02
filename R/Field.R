Field <- R6::R6Class( # nolint object_name_linter
  "Field",
  cloneable = FALSE,
  public = list(
    initialize = function(type,
                          through,
                          field_name,
                          model_name,
                          column_name,
                          schema_name,
                          is_link_table,
                          relation_type,
                          related_field_name,
                          related_model_name,
                          related_schema_name) {
      private$.type <- type
      private$.through <- through
      private$.field_name <- field_name
      private$.model_name <- model_name
      private$.column_name <- column_name
      private$.schema_name <- schema_name
      private$.is_link_table <- is_link_table
      private$.relation_type <- relation_type
      private$.related_field_name <- related_field_name
      private$.related_model_name <- related_model_name
      private$.related_schema_name <- related_schema_name
    }
  ),
  private = list(
    .type = NULL,
    .through = NULL,
    .field_name = NULL,
    .model_name = NULL,
    .column_name = NULL,
    .schema_name = NULL,
    .is_link_table = NULL,
    .relation_type = NULL,
    .related_field_name = NULL,
    .related_model_name = NULL,
    .related_schema_name = NULL
  ),
  active = list(
    type = function() {
      private$.type
    },
    through = function() {
      private$.through
    },
    field_name = function() {
      private$.field_name
    },
    model_name = function() {
      private$.model_name
    },
    column_name = function() {
      private$.column_name
    },
    schema_name = function() {
      private$.schema_name
    },
    is_link_table = function() {
      private$.is_link_table
    },
    relation_type = function() {
      private$.relation_type
    },
    related_field_name = function() {
      private$.related_field_name
    },
    related_model_name = function() {
      private$.related_model_name
    },
    related_schema_name = function() {
      private$.related_schema_name
    }
  )
)
