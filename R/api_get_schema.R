api_get_schema <- function(instance_settings) {
  httr::GET(
    paste0(
      instance_settings$api_url,
      "/instances/",
      instance_settings$id,
      "/schema"
    )
  ) |>
    httr::content()
}
