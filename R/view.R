view_lineage_graph <- function(self, ...) {
  py_object <- unwrap_python(self)
  args <- list(...)

  return_graph <- args$return_graph
  args$return_graph <- TRUE

  graph <- unwrap_args_and_call(py_object$view_lineage, args)

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
