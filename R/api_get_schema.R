api_get_schema <- function(api, instance_settings) {
  operations <- rapiclient::get_operations(api)

  operations$get_schema_instances__instance_id__schema_get(instance_id) |>
    httr::content()
}
