skip_if_offline()

broken_instance_settings <- function() {
  InstanceSettings$new(
    list(
      owner = "foo",
      name = "bar",
      id = "...",
      schema_str = "foo,bar",
      schema_id = "...",
      git_repo = "...",
      keep_artifacts_local = TRUE,
      api_url = "https://foo.lamin.ai"
    )
  )
}

test_that("get_schema works", {
  local_setup_lamindata_instance()

  instance_file <- .settings_store__instance_settings_file("laminlabs", "lamindata")
  instance_settings <- .settings_load__load_instance_settings()

  api <- InstanceAPI$new(instance_settings)

  # try to get the schema
  schema <- api$get_schema()

  expect_named(schema, c("core", "bionty", "wetlab"))

  expect_true(all(c("run", "user", "param", "artifact", "storage") %in% names(schema$core)))

  expect_named(schema$core$artifact, c("fields_metadata", "class_name", "is_link_table"))
})

test_that("get_schema fails gracefully", {
  instance_settings <- broken_instance_settings()

  api <- InstanceAPI$new(instance_settings)

  expect_error(api$get_schema(), regexp = "Could not resolve host: foo.lamin.ai")
})

test_that("get_record works", {
  local_setup_lamindata_instance()

  instance_file <- .settings_store__instance_settings_file("laminlabs", "lamindata")
  instance_settings <- .settings_load__load_instance_settings()

  api <- InstanceAPI$new(instance_settings)

  # try to get a record
  artifact <- api$get_record("core", "artifact", "mePviem4DGM4SFzvLXf3")

  expect_true(all(c("uid", "size", "hash", "description", "type") %in% names(artifact)))
})

test_that("test get_record fails gracefully with incorrect host", {
  instance_settings <- broken_instance_settings()

  api <- InstanceAPI$new(instance_settings)

  # try to get a record
  expect_error(
    api$get_record("core", "artifact", "mePviem4DGM4SFzvLXf3"),
    regexp = "Could not resolve host: foo.lamin.ai"
  )
})

test_that("get_record with select works", {
  local_setup_lamindata_instance()

  instance_file <- .settings_store__instance_settings_file("laminlabs", "lamindata")
  instance_settings <- .settings_load__load_instance_settings()

  api <- InstanceAPI$new(instance_settings)

  # try to get a record
  artifact <- api$get_record("core", "artifact", "mePviem4DGM4SFzvLXf3", select = "storage")

  expect_true(all(c("uid", "size", "hash", "description", "type") %in% names(artifact)))

  expect_true(all(c("uid", "type", "region", "root") %in% names(artifact$storage)))
})

test_that("get_record fails gracefully", {
  local_setup_lamindata_instance()

  instance_file <- .settings_store__instance_settings_file("laminlabs", "lamindata")
  instance_settings <- .settings_load__load_instance_settings()

  api <- InstanceAPI$new(instance_settings)

  expect_error(
    api$get_record("core", "artifact", "foobar"),
    regexp = "404: Record not found"
  )

  # nolint start: commented_code
  # TODO: improve error messages for these cases
  expect_error(
    api$get_record("core", "artifact", "mePviem4DGM4SFzvLXf3", select = "foo"),
    # regexp = "Error getting record: invalid select field: foo"
  )
  # nolint end: commented_code
})

test_that("get_records works", {
  local_setup_lamindata_instance()

  instance_file <- .settings_store__instance_settings_file("laminlabs", "lamindata")
  instance_settings <- .settings_load__load_instance_settings()

  api <- InstanceAPI$new(instance_settings)

  records <- api$get_records("core", "storage")

  expect_type(records, "list")
  expect_type(records[[1]], "list")
  expect_true(all(c("description", "created_at", "id", "uid") %in% names(records[[1]])))
})
