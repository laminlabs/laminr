create_instance <- function(instance_settings) {
  super <- NULL # satisfy linter

  api <- InstanceAPI$new(instance_settings = instance_settings)

  # fetch schema from the API
  schema <- api$get_schema()

  # create active fields for the exposed instance
  active <- list()

  # add core registries to active fields
  for (registry_name in names(schema$core)) {
    registry <- schema$core[[registry_name]]

    if (registry$is_link_table) {
      next
    }

    fun_src <- paste0(
      "function() {",
      "  private$.module_classes$core$get_registry('", registry_name, "')",
      "}"
    )

    active[[registry$class_name]] <- eval(parse(text = fun_src))
  }

  # add non-core modules to active fields
  for (module_name in names(schema)) {
    if (module_name == "core") {
      next
    }

    fun_src <- paste0(
      "function() {",
      "  private$.module_classes[['", module_name, "']]",
      "}"
    )
    active[[module_name]] <- eval(parse(text = fun_src))
  }

  # create the instance class
  RichInstance <- R6::R6Class( # nolint object_name_linter
    instance_settings$name,
    cloneable = FALSE,
    inherit = Instance,
    public = list(
      initialize = function(settings, api, schema) {
        super$initialize(
          settings = settings,
          api = api,
          schema = schema
        )
      }
    ),
    active = active
  )

  # create the instance
  RichInstance$new(settings = instance_settings, api = api, schema = schema)
}

#' @title Instance
#'
#' @description
#' Connect to a LaminDB instance using the [connect()] function.
#' The instance object provides access to the modules and registries
#' of the instance.
#'
#' @details
#' Note that by connecting to an instance via [connect()], you receive
#' a "richer" version of the Instance class documented here, providing
#' direct access to all core registries and additional modules.
#' See the vignette on "Package Architecture" for more information:
#' `vignette("architecture", package = "laminr")`.
#'
#' @examples
#' \dontrun{
#' # Connect to an instance
#' db <- connect("laminlabs/cellxgene")
#'
#' # fetch an artifact
#' artifact <- db$Artifact$get("KBW89Mf7IGcekja2hADu")
#'
#' # describe the artifact
#' artifact$describe()
#'
#' # view field
#' artifact$id
#'
#' # load dataset
#' artifact$load()
#' }
Instance <- R6::R6Class( # nolint object_name_linter
  "Instance",
  cloneable = FALSE,
  public = list(
    #' @description
    #' Creates an instance of this R6 class. This class should not be instantiated directly,
    #' but rather by connecting to a LaminDB instance using the [connect()] function.
    #'
    #' @param settings The settings for the instance
    #' @param api The API for the instance
    #' @param schema The schema for the instance
    initialize = function(settings, api, schema) {
      private$.settings <- settings
      private$.api <- api

      # create module classes from the schema
      private$.module_classes <- map(
        names(schema),
        function(module_name) {
          create_module(
            instance = self,
            api = private$.api,
            module_name = module_name,
            module_schema = schema[[module_name]]
          )
        }
      ) |>
        set_names(names(schema))
    },
    #' @description Get the modules for the instance.
    #'
    #' @return A list of [Module] objects.
    get_modules = function() {
      private$.module_classes
    },
    #' @description Get a module by name.
    #'
    #' @param module_name The name of the module.
    #'
    #' @return The [Module] object.
    get_module = function(module_name) {
      # todo: assert module exists
      private$.module_classes[[module_name]]
    },
    #' @description Get the names of the modules. Example: `c("core", "bionty")`.
    #'
    #' @return A character vector of module names.
    get_module_names = function() {
      names(private$.module_classes)
    },
    #' @description Get instance settings.
    #'
    #' Note: This method is intended for internal use only and may be removed in the future.
    #'
    #' @return The settings for the instance.
    get_settings = function() {
      private$.settings
    },
    #' @description Get instance API.
    #'
    #' Note: This method is intended for internal use only and may be removed in the future.
    #'
    #' @return The API for the instance.
    get_api = function() {
      private$.api
    },
    #' @description
    #' Print an `Instance`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    print = function(style = TRUE) {
      registries <- self$get_module("core")$get_registries()

      is_link_table <- purrr::map(registries, "is_link_table") |>
        unlist()

      standard_lines <- purrr::map_chr(
        names(registries)[!is_link_table],
        function(.registry) {
          paste0("    $", registries[[.registry]]$class_name)
        }
      )

      lines <- c(
        cli::style_bold(cli::col_br_green(private$.settings$name)),
        cli::style_italic(cli::col_br_magenta("  Core registries")),
        standard_lines
      )

      module_names <- self$get_module_names()
      module_names <- module_names[module_names != "core"]

      if (length(module_names) > 0) {
        lines <- c(
          lines,
          cli::style_italic(cli::col_br_magenta("  Additional modules")),
          paste0("    ", module_names)
        )
      }

      if (isFALSE(style)) {
        lines <- cli::ansi_strip(lines)
      }

      purrr::walk(lines, cli::cat_line)
    },
    #' @description
    #' Create a string representation of an `Instance`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      registries <- self$get_module("core")$get_registries()

      is_link_table <- purrr::map(registries, "is_link_table") |>
        unlist()

      mapping <- list(
        "CoreRegistries" = paste0(
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
      )

      module_names <- self$get_module_names()
      module_names <- module_names[module_names != "core"]

      if (length(module_names) > 0) {
        mapping["AdditionalModules"] <- paste0(
          "[",
          paste(module_names, collapse = ", "),
          "]"
        )
      }

      key_value_strings <- make_key_value_strings(
        mapping,
        quote_strings = FALSE
      )

      make_class_string(
        private$.settings$name, key_value_strings,
        style = style
      )
    }
  ),
  private = list(
    .settings = NULL,
    .api = NULL,
    .module_classes = NULL
  )
)
