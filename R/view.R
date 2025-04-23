view_lineage_graph <- function(artifact, with_children = TRUE, return_graph = FALSE) {
  py_artifact <- unwrap_python(artifact)

  graph <- py_artifact$view_lineage(
    with_children = with_children, return_graph = TRUE
  )

  if (return_graph) {
    return(graph)
  }

  if (interactive()) {
    image_file <- graph$render(directory = tempdir(), format = "svg")

    if (is_rstudio()) { # nolint object_usage_linter
      rstudioapi::viewer(image_file)
    } else {
      utils::browseURL(image_file)
    }
  } else {
    check_requires("Displaying lineages in a notebook", "magick")

    image_file <- graph$render(directory = tempdir(), format = "png")
    image_object <- magick::image_read(image_file)

    plot(image_object)
  }
}
