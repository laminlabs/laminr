#' InstanceSettings class
#'
#' The InstanceSettings class is used to store the settings of a LaminDB instance.
#'
#' @importFrom R6 R6Class
#'
#' @noRd
InstanceSettings <- R6::R6Class(
  "InstanceSettings",
  cloneable = FALSE,
  public = list(
    #' @field url The base URL of the LaminDB API.
    url = NULL,
    #' @field instance_id The instance ID of the LaminDB instance.
    instance_id = NULL,
    #' @field schema_id The schema ID of the LaminDB schema.
    schema_id = NULL,
    #' Initialize the InstanceSettings class
    #'
    #' @param url The base URL of the LaminDB API.
    #' @param instance_id The instance ID of the LaminDB instance.
    #' @param schema_id The schema ID of the LaminDB schema.
    initialize = function(
      url,
      instance_id,
      schema_id
    ) {
      self$url <- url
      self$instance_id <- instance_id
      self$schema_id <- schema_id
    }
  )
)
