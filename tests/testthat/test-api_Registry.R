skip_if_offline()

test_that("df works", {
  skip_if_not_logged_in()

  db <- api_connect("laminlabs/lamindata")

  records <- db$Storage$df()

  expect_s3_class(records, "data.frame")
  expect_true(all(c("description", "created_at", "id", "uid") %in% colnames(records)))
})

test_that("to_string works", {
  skip_if_not_logged_in()

  db <- api_connect("laminlabs/lamindata")

  str <- db$bionty$Phenotype$to_string()

  expect_type(str, "character")

  regex <- paste0(
    "Phenotype\\(",
    "SimpleFields=\\[id, uid,[^\\]*\\], ",
    "RelationalFields=\\[[^\\]*\\], ",
    "BiontyFields=\\[[^\\]*\\]",
    "\\)"
  )

  expect_match(str, regex)
})

test_that("print works", {
  skip_if_not_logged_in()

  db <- api_connect("laminlabs/lamindata")

  regex <- paste0(
    "Phenotype\n",
    "  Simple fields\n",
    "    id: AutoField\n",
    "    uid: CharField\n",
    ".*",
    "  Relational fields\n",
    "    run: Run \\(many-to-one\\)\n",
    ".*",
    "  Bionty fields\n",
    "    source: bionty\\$Source \\(many-to-one\\)\n",
    ".*"
  )

  expect_output(db$bionty$Phenotype$print(style = FALSE), regex)
})
