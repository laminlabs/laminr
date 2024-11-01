create_module <- function(instance, api, module_name, module_schema) {
  super <- NULL # satisfy linter

  # create active fields for the exposed instance
  active <- list()

  # add registries to active fields
  for (registry_name in names(module_schema)) {
    registry <- module_schema[[registry_name]]

    if (registry$is_link_table) {
      next
    }

    fun_src <- paste0(
      "function() {",
      "  private$.registry_classes[['", registry_name, "']]",
      "}"
    )
    active[[registry$class_name]] <- eval(parse(text = fun_src))
  }

  # create the module class
  RichModule <- R6::R6Class( # nolint object_name_linter
    module_name,
    cloneable = FALSE,
    inherit = Module,
    public = list(
      initialize = function(instance, api, module_name, module_schema) {
        super$initialize(
          instance = instance,
          api = api,
          module_name = module_name,
          module_schema = module_schema
        )
      }
    ),
    active = active
  )

  # create the module
  RichModule$new(instance, api, module_name, module_schema)
}

#' @title Module
#'
#' @description
#' A LaminDB module containing one or more registries.
Module <- R6::R6Class( # nolint object_name_linter
  "Module",
  cloneable = FALSE,
  public = list(
    #' @description
    #' Creates an instance of this R6 class. This class should not be instantiated directly,
    #' but rather by connecting to a LaminDB instance using the [connect()] function.
    #'
    #' @param instance The instance the module belongs to.
    #' @param api The API for the instance.
    #' @param module_name The name of the module.
    #' @param module_schema The schema of the module.
    initialize = function(instance, api, module_name, module_schema) {
      private$.instance <- instance
      private$.api <- api
      private$.module_name <- module_name

      private$.registry_classes <- map(
        names(module_schema),
        function(registry_name) {
          Registry$new(
            instance = instance,
            module = self,
            api = api,
            registry_name = registry_name,
            registry_schema = module_schema[[registry_name]]
          )
        }
      ) |>
        set_names(names(module_schema))
    },
    #' @description Get the registries in the module.
    #'
    #' @return A list of [Registry] objects.
    get_registries = function() {
      private$.registry_classes
    },
    #' @description Get a registry by name.
    #'
    #' @param registry_name The name of the registry.
    #'
    #' @return A [Registry] object.
    get_registry = function(registry_name) {
      private$.registry_classes[[registry_name]]
    },
    #' @description Get the names of the registries in the module. E.g. `c("User", "Artifact")`.
    #'
    #' @return A character vector of registry names.
    get_registry_names = function() {
      names(private$.registry_classes)
    },
    #' @description Print a `Module`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes.
    print = function(style = TRUE) {
      registries <- self$get_registries()

      is_link_table <- purrr::map(registries, "is_link_table") |>
        unlist()

      standard_lines <- purrr::map_chr(
        names(registries)[!is_link_table],
        function(.registry) {
          paste0("    $", registries[[.registry]]$class_name)
        }
      )

      lines <- c(
        cli::style_bold(cli::col_br_green(private$.module_name)),
        cli::style_italic(cli::col_br_magenta("  Registries")),
        standard_lines
      )

      if (isFALSE(style)) {
        lines <- cli::ansi_strip(lines)
      }

      purrr::walk(lines, cli::cat_line)
    },
    #' @description
    #' Create a string representation of a `Module`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      registries <- self$get_registries()

      is_link_table <- purrr::map(registries, "is_link_table") |>
        unlist()

      registry_strings <- make_key_value_strings(
        list(
          "Registries" = paste0(
            "[",
            paste(
              paste0(
                "$",
                purrr::map_chr(registries[!is_link_table], "class_name")
              ),
              collapse = ", "
            ),
            "]"
          )
        ),
        quote_strings = FALSE
      )

      make_class_string(private$.module_name, registry_strings, style = style)
    }
  ),
  private = list(
    .instance = NULL,
    .api = NULL,
    .module_name = NULL,
    .registry_classes = NULL
  ),
  active = list(
    #' @field name (`character(1)`)\cr
    #' Get the name of the module.
    name = function() {
      private$.module_name
    }
  )
)
