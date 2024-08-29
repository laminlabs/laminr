# TODO: align with Python's InstanceSettings
# https://github.com/laminlabs/lamindb-setup/blob/main/lamindb_setup/core/_settings_instance.py#L42

#' InstanceSettings class
#'
#' The InstanceSettings class is used to store the settings of a LaminDB instance.
#'
#' @importFrom R6 R6Class
#'
#' @noRd
InstanceSettings <- R6::R6Class( # nolint object_name_linter
  "InstanceSettings",
  cloneable = FALSE,
  public = list(
    #' @field owner The owner of the LaminDB instance.
    owner = NULL,
    #' @field name The name of the LaminDB instance.
    name = NULL,
    #' @field url The base URL of the LaminDB API.
    api_url = NULL,
    #' @field id The instance ID of the LaminDB instance.
    id = NULL,
    #' @field schema_id The schema ID of the LaminDB schema.
    schema_id = NULL,
    #' Initialize the InstanceSettings class
    #'
    #' @param id The instance ID of the LaminDB instance.
    #' @param owner The owner of the LaminDB instance.
    #' @param name The name of the LaminDB instance.
    #' @param api_url The base URL of the LaminDB API.
    #' @param schema_id The schema ID of the LaminDB schema.
    initialize = function(
      id,
      owner,
      name,
      url,
      schema_id
    ) {
      self$id <- id
      self$owner <- owner
      self$name <- name
      self$api_url <- api_url
      self$schema_id <- schema_id
    }
  )
)
