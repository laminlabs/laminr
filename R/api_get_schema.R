api_get_schema <- function(instance_settings) {
  httr::GET(
    paste0(
      instance_settings$url,
      "/instances/",
      instance_settings$instance_id,
      "/schema"
    )
  ) |>
    httr::content()
}
