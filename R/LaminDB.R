# private <- list()
# self <- list(
#   url = "https://us-west-2.api.lamin.ai",
#   instance_id = "399387d4-feec-45b5-995d-5b5750f5542c",
#   schema_id = "a122335a-0d85-cf36-291d-9e98a6dd1417"
# )

#' @title LaminDB class
#' 
#' @description This class is used to interact with the LaminDB API.
#' 
#' @param url The base URL of the LaminDB API.
#' @param instance_id The instance ID of the LaminDB instance.
#' @param schema_id The schema ID of the LaminDB schema.
#' 
#' @importFrom httr content
#' @importFrom purrr pmap
#' @importFrom dplyr filter %>%
#' @importFrom dynutils list_as_tibble
#' @importFrom R6 R6Class
#' @importFrom rapiclient get_api get_operations
#' 
#' @export
LaminDB <- R6::R6Class(
  "LaminDB",
  public = list(
    #' @field types Object types defined by the LaminDB schema
    types = NULL,
    #' Initialize the LaminDB class
    #' 
    #' @param url The base URL of the LaminDB API.
    #' @param instance_id The instance ID of the LaminDB instance.
    #' @param schema_id The schema ID of the LaminDB schema.
    initialize = function(
      url,
      instance_id,
      schema_id
    ) {
      private$url <- url
      private$instance_id <- instance_id
      private$schema_id <- schema_id

      private$parse_api()
      private$load_schemas()
      private$generate_classes()
    }
  ),
  private = list(
    url = NULL,
    instance_id = NULL,
    schema_id = NULL,
    api = NULL,
    operations = NULL,
    schemas = NULL,
    parse_api = function() {
      private$api <- suppressWarnings(
        rapiclient::get_api(url = paste0(private$url, "/openapi.json"))
      )
      private$operations <- rapiclient::get_operations(private$api)
    },
    load_schemas = function() {
      private$schemas <-
        private$operations$get_schema_instances__instance_id__schema__get(
          instance_id = private$instance_id
        ) |>
        httr::content()
    },
    #' importFrom dplyr filter %>%
    #' importFrom purrr pmap
    generate_class = function(
      module_name,
      model_name
    ) {
      class_name <- private$schemas[[module_name]][[model_name]]$class_name
      fields_metadata <- private$schemas[[module_name]][[model_name]]$fields_metadata

      fields <- fields_metadata %>%
        unname() %>%
        dynutils::list_as_tibble() %>%
        filter(model_name == !!model_name) %>%
        filter(!is.na(column)) %>%
        unique()

      related_fields <- fields %>%
        filter(!is.na(relation_type))

      # generate initialize function
      initialize_fun <- NULL
      initialize_fun_src <- paste0(
        "initialize_fun <- function(",
        paste(paste0("  `", fields$column, "` = NULL,\n"), collapse = ""),
        "  db\n",
        ") {\n",
        paste(
          paste0("  self$`", fields$column, "` <- `", fields$column, "`\n"),
          collapse = ""
        ),
        "  private$db <- db\n",
        "}\n"
      )
      eval(parse(text = initialize_fun_src))

      print_fun <- function(...) {
        cat(class_name, ":\n")
        for (field in fields$column) {
          cat("  ", field, ": ", self$`[[field]]`, "\n", sep = "")
        }
      }

      print_fun <- NULL
      print_fun_src <- paste0(
        "print_fun <- function(...) {\n",
        "  cat('", class_name, ":\\n')\n",
        paste(
          paste0("  cat('  ', '", fields$column, "', ': ', self$`", fields$column, "`, '\\n', sep = '')\n"),
          collapse = ""
        ),
        "}\n"
      )
      eval(parse(text = print_fun_src))

      # generate initial values
      public_fields <- setNames(
        lapply(fields$column, function(x) NULL),
        fields$column
      )
      
      # generate relation lookup functions
      lookup_funs <- setNames(
        pmap(related_fields, function(related_schema_name, related_model_name, column, ...) {
          lookup_fun_src <- paste0(
            "lookup_fun <- function() {\n",
            "  type <- private$db$types[['", related_schema_name, "']][['", related_model_name, "']]\n",
            "  type$get_record(self$`", column, "`)\n",
            "}\n"
          )
          lookup_fun <- NULL
          eval(parse(text = lookup_fun_src))
          lookup_fun
        }),
        related_fields$field_name
      )

      cls <- R6::R6Class(
        class_name,
        public = c(
          list(
            initialize = initialize_fun,
            print = print_fun
          ),
          public_fields,
          lookup_funs
        ),
        private = list(
          db = NULL
        ),
        cloneable = FALSE
      )

      cls$get_record <- function(id_or_uid) {
        cat("Fetching record for ", module_name, ".", model_name, " with id_or_uid: ", id_or_uid, "\n", sep = "")
        data <-
          private$operations$get_record_instances__instance_id__modules__module_name___model_name___id_or_uid__post(
            instance_id = private$instance_id,
            schema_id = private$schema_id,
            module_name = module_name,
            model_name = model_name,
            id_or_uid = id_or_uid
          ) |>
          content()
        expected_fields <- fields$column
        found_fields <- names(data)

        if (!all(expected_fields %in% found_fields)) {
          warning(
            "Expected fields not found in data: ",
            paste(setdiff(expected_fields, found_fields), collapse = ", ")
          )
        }
        if (!all(found_fields %in% expected_fields)) {
          warning(
            "Unexpected fields found in data: ",
            paste(setdiff(found_fields, expected_fields), collapse = ", ")
          )
        }

        intersect_data <- data[intersect(expected_fields, found_fields)]

        do.call(cls$new, c(intersect_data, list(db = self)))
      }

      cls
    },
    generate_classes = function() {
      classes <- list()
      for (module_name in names(private$schemas)) {
        module <- list()
        for (model_name in names(private$schemas[[module_name]])) {
          module[[model_name]] <- 
            tryCatch({
              private$generate_class(module_name, model_name)
            }, error = function(e) {
              warning(
                "Failed to generate class for ",
                module_name,
                ".",
                model_name,
                ": ",
                e$message
              )
              NULL
            })
        }
        classes[[module_name]] <- module
      }
      self$types <- classes
    }
  )
)