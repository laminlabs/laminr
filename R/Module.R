create_module <- function(instance, api, module_name, module_schema) {
  super <- NULL # satisfy linter

  # create active fields for the exposed instance
  active <- list()

  # add models to active fields
  for (model_name in names(module_schema)) {
    model <- module_schema[[model_name]]

    if (model$is_link_table) {
      next
    }

    fun <- NULL
    fun_src <- paste0(
      "fun <- function() {",
      "  self$get_model('", model_name, "')",
      "}"
    )
    eval(parse(text = fun_src))

    active[[model$class_name]] <- fun
  }

  # create the module class
  CurrentModule <- R6::R6Class( # nolint object_name_linter
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
  CurrentModule$new(instance, api, module_name, module_schema)
}

Module <- R6::R6Class( # nolint object_name_linter
  "Module",
  cloneable = FALSE,
  public = list(
    initialize = function(instance, api, module_name, module_schema) {
      private$.instance <- instance
      private$.api <- api
      private$.module_name <- module_name

      private$.model_classes <- map(
        names(module_schema),
        function(model_name) {
          Model$new(
            instance = instance,
            module = self,
            api = api,
            model_name = model_name,
            model_schema = module_schema[[model_name]]
          )
        }
      ) |>
        set_names(names(module_schema))
    },
    get_models = function() {
      private$.model_classes
    },
    get_model = function(model_name) {
      private$.model_classes[[model_name]]
    },
    get_model_names = function() {
      names(private$.model_classes)
    }
  ),
  private = list(
    .instance = NULL,
    .api = NULL,
    .module_name = NULL,
    .model_classes = NULL
  ),
  active = list(
    name = function() {
      private$.module_name
    }
  )
)
