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
    url = NULL,
    #' @field instance_id The instance ID of the LaminDB instance.
    instance_id = NULL,
    #' @field schema_id The schema ID of the LaminDB schema.
    schema_id = NULL,
    #' Initialize the InstanceSettings class
    #'
    #' @param owner The owner of the LaminDB instance.
    #' @param name The name of the LaminDB instance.
    #' @param url The base URL of the LaminDB API.
    #' @param instance_id The instance ID of the LaminDB instance.
    #' @param schema_id The schema ID of the LaminDB schema.
    initialize = function(
      owner,
      name,
      url,
      instance_id,
      schema_id
    ) {
      self$owner <- owner
      self$name <- name
      self$url <- url
      self$instance_id <- instance_id
      self$schema_id <- schema_id
    }
  )
)
