create_instance <- function(instance_settings, is_default = FALSE) {
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
      initialize = function(settings, api, schema, is_default, py_lamin) {
        super$initialize(
          settings = settings,
          api = api,
          schema = schema,
          is_default = is_default,
          py_lamin = py_lamin
        )
      }
    ),
    active = active
  )

  py_lamin <- NULL
  if (isTRUE(is_default)) {
    check_requires("Connecting to Python", "reticulate", type = "warning")

    py_lamin <- tryCatch(
      reticulate::import("lamindb"),
      error = function(err) {
        cli::cli_warn(c(
          paste(
            "Failed to connect to the Python {.pkg lamindb} package,",
            "you will not be able to create records"
          ),
          "i" = "See {.run reticulate::py_config()} for more information"
        ))
        NULL
      }
    )
  }

  # create the instance
  RichInstance$new(
    settings = instance_settings,
    api = api,
    schema = schema,
    is_default = is_default,
    py_lamin = py_lamin
  )
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
    #' @param is_default Logical, whether this is the default instance
    #' @param py_lamin A Python `lamindb` module object
    initialize = function(settings, api, schema, is_default, py_lamin) {
      private$.settings <- settings
      private$.api <- api
      private$.is_default <- is_default
      private$.py_lamin <- py_lamin

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
    #' @description Get the Python lamindb module
    #'
    #' @param check Logical, whether to perform checks
    #' @param what What the python module is being requested for, used in check
    #'   messages
    #'
    #' @return Python lamindb module.
    get_py_lamin = function(check = FALSE, what = "This functionality") {
      if (check && isFALSE(self$is_default)) {
        cli::cli_abort(c(
          "{what} can only be performed by the default instance",
          "i" = "Use {.code connect(slug = NULL)} to connect to the default instance"
        ))
      }

      if (check && is.null(self$get_py_lamin())) {
        cli::cli_abort(c(
          "{what} requires the Python lamindb package",
          "i" = "Check the output of {.code connect()} for warnings"
        ))
      }

      private$.py_lamin
    },
    #' @description Start a run with tracked data lineage
    #'
    #' @details
    #' Calling `track()` with `transform = NULL` with return a UID, providing
    #' that UID with the same path with start a run
    #'
    #' @param transform UID specifying the data transformation
    #' @param path Path to the R script or document to track
    track = function(transform = NULL, path = NULL) {
      py_lamin <- self$get_py_lamin(check = TRUE, what = "Tracking")

      if (is.null(path)) {
        path <- detect_path()
        if (is.null(path)) {
          cli::cli_abort(
            "Failed to detect the path to track. Please set the {.arg path} argument."
          )
        }
      }

      if (is.null(transform)) {
        transform <- tryCatch(
          py_lamin$track(path = path),
          error = function(err) {
            py_err <- reticulate::py_last_error()
            # please don't change the below without changing it in lamindb
            if (py_err$type != "MissingContextUID") {
              cli::cli_abort(c(
                "Python {py_err$message}",
                "i" = "Run {.run reticulate::py_last_error()} for details"
              ))
            }

            uid <- gsub(".*\\(\"(.*?)\"\\).*", "\\1", py_err$value)
            cli::cli_inform(paste(
              "To track this notebook, run: db$track(\"{uid}\")"
            ))
          }
        )
      } else {
        if (is.character(transform) && nchar(transform) != 16) {
          cli::cli_abort(
            "The transform UID must be exactly 16 characters, got {nchar(transform)}"
          )
        }

        py_lamin$track(transform = transform, path = path)
      }
    },
    #' @description Finish a tracked run
    finish = function() {
      py_lamin <- self$get_py_lamin(check = TRUE, what = "Tracking")
      tryCatch(
        py_lamin$finish(),
        error = function(err) {
          py_err <- reticulate::py_last_error()
          if (py_err$type != "NotebookNotSaved") {
            cli::cli_abort(c(
              "Python {py_err$message}",
              "i" = "Run {.run reticulate::py_last_error()} for details"
            ))
          }
          # please don't change the below without changing it in lamindb
          message <- gsub(".*NotebookNotSaved: (.*)$", "\\1", py_err$value)
          cli::cli_inform(paste("NotebookNotSaved: {message}"))
        }
      )
    }, 
    #' @description
    #' Print an `Instance`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    print = function(style = TRUE) {
      registries <- self$get_module("core")$get_registries()

      is_link_table <- map(registries, "is_link_table") |>
        unlist()

      standard_lines <- map_chr(
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

      walk(lines, cli::cat_line)
    },
    #' @description
    #' Create a string representation of an `Instance`
    #'
    #' @param style Logical, whether the output is styled using ANSI codes
    #'
    #' @return A `cli::cli_ansi_string` if `style = TRUE` or a character vector
    to_string = function(style = FALSE) {
      registries <- self$get_module("core")$get_registries()

      is_link_table <- map(registries, "is_link_table") |>
        unlist()

      mapping <- list(
        "CoreRegistries" = paste0(
          "[",
          paste(
            paste0(
              "$",
              map_chr(registries[!is_link_table], "class_name")
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
  active = list(
    #' @field is_default (`logical(1)`)\cr
    #' Whether this is the default instance.
    is_default = function() {
      private$.is_default
    }
  ),
  private = list(
    .settings = NULL,
    .api = NULL,
    .module_classes = NULL,
    .is_default = NULL,
    .py_lamin = NULL
  )
)
