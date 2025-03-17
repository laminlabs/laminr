test_that("load_file with a .csv works", {
  skip_if_not_installed("readr")

  file <- withr::local_file(tempfile(fileext = ".csv"))

  # create a CSV file
  df <- data.frame(a = 1L:3L, b = c("a", "b", "c"))
  readr::write_csv(df, file)

  # load the CSV file
  loaded_df <- load_file(file, show_col_types = FALSE)

  # ignore class differences
  class(loaded_df) <- class(df)

  # check that the data frame is the same
  expect_equal(loaded_df, df, ignore_attr = TRUE)
})

test_that("load_file with a .tsv works", {
  skip_if_not_installed("readr")

  file <- withr::local_file(tempfile(fileext = ".tsv"))

  # create a TSV file
  df <- data.frame(a = 1L:3L, b = c("a", "b", "c"))
  readr::write_tsv(df, file)

  # load the TSV file
  loaded_df <- load_file(file, show_col_types = FALSE)

  # ignore class differences
  class(loaded_df) <- class(df)

  # check that the data frame is the same
  expect_equal(loaded_df, df, ignore_attr = TRUE)
})

test_that("load_file with an .h5ad works", {
  skip_if_not_installed("anndata")
  skip_if_not_installed("reticulate")
  skip_if_not(reticulate::py_module_available("anndata"))

  file <- withr::local_file(tempfile(fileext = ".h5ad"))

  warnings <- reticulate::import("warnings")
  warnings$filterwarnings("ignore")

  # create an AnnData object
  adata <- anndata::AnnData(
    X = matrix(1L:6L, nrow = 3),
    obs = data.frame(a = 1L:3L),
    var = data.frame(b = c("a", "b"))
  )

  adata$write_h5ad(file)

  # load the AnnData object
  loaded_adata <- load_file(file)

  # check that the AnnData object is the same
  expected <- capture_output(print(adata))
  actual <- capture_output(print(loaded_adata))
  expect_equal(actual, expected)

  expect_equal(loaded_adata$obs, adata$obs, ignore_attr = TRUE)
  expect_equal(loaded_adata$var, adata$var, ignore_attr = TRUE)
  expect_equal(loaded_adata$X, adata$X, ignore_attr = TRUE)
})

###################### TODO: add anndata_zarr tests ######################

test_that("load_file with a .parquet works", {
  skip_if_not_installed("nanoparquet")

  file <- withr::local_file(tempfile(fileext = ".parquet"))

  # create a Parquet file
  df <- data.frame(a = 1:3, b = 4:6)
  nanoparquet::write_parquet(df, file)

  # load the Parquet file
  loaded_df <- load_file(file)

  # ignore class differences
  class(loaded_df) <- class(df)

  # check that the data frame is the same
  expect_equal(loaded_df, df)
})

###################### TODO: add load_fcs tests ######################

###################### TODO: add load_h5mu tests ######################

test_that("load_file with a .html works", {
  skip_if_not_installed("knitr")

  file <- withr::local_file(tempfile(fileext = ".html"))

  # create an HTML file
  html <- "<html><body><h1>Hello, world!</h1></body></html>"
  writeLines(html, file)

  # pretend we are in a knitr notebook
  knitr::opts_knit$set(out.format = "html")
  on.exit(knitr::opts_knit$set(out.format = NULL))

  # load the HTML file
  loaded_html <- load_file(file)

  # check that output is a knit_asis
  expect_s3_class(loaded_html, "knit_asis")

  # check that the HTML is the same
  expected_html <- paste0("\n```{=html}\n", html, "\n```\n")
  expect_equal(
    unclass(loaded_html),
    expected_html,
    ignore_attr = TRUE
  )
})

test_that("load_file with a .json works", {
  skip_if_not_installed("jsonlite")

  file <- withr::local_file(tempfile(fileext = ".json"))

  data <- list(
    a = c(1, 2, 3),
    b = c(3, 4, 5)
  )

  jsonlite::write_json(data, file)

  loaded_data <- load_file(file)

  expect_equal(loaded_data, data)
})

test_that("load_file with an .svg works", {
  skip_if_not_installed("knitr")

  file <- withr::local_file(tempfile(fileext = ".svg"))

  # create an SVG file
  svg <- "<svg><text x='0' y='15'>Hello, world!</text></svg>"
  writeLines(svg, file)

  # pretend we are in a knitr notebook
  knitr::opts_knit$set(out.format = "html")
  on.exit(knitr::opts_knit$set(out.format = NULL))

  # load the SVG file
  loaded_svg <- load_file(file)

  # check that output is a knit_asis
  expect_s3_class(loaded_svg, c("knit_image_paths", "knit_asis"))

  # check that the SVG is the same
  expect_equal(unclass(loaded_svg), file)
})

test_that("load_file with an .rds works", {
  file <- withr::local_file(tempfile(fileext = ".rds"))

  data <- list(
    a = c(1, 2, 3),
    b = c(3, 4, 5)
  )

  saveRDS(data, file)

  loaded_data <- load_file(file)

  expect_equal(loaded_data, data)
})

test_that("load_file with a .yaml works", {
  skip_if_not_installed("yaml")

  file <- withr::local_file(tempfile(fileext = ".yaml"))

  data <- list(
    a = c(1, 2, 3),
    b = c(3, 4, 5)
  )

  yaml::write_yaml(data, file)

  loaded_data <- load_file(file)

  expect_equal(loaded_data, data)
})
