# Import Python modules

This function can be used to import **LaminDB** Python modules with
additional checks and nicer error messages.

## Usage

``` r
import_module(module, ...)
```

## Arguments

- module:

  The name of the Python module to import

- ...:

  Arguments passed on to
  [`require_module`](https://laminr.lamin.ai/reference/require_module.md)

  `options`

  :   A vector of defined optional dependencies for the module that is
      being required

  `version`

  :   A string specifying the version of the module to require

  `source`

  :   A source for the module requirement, for example
      `git+https://github.com/owner/module.git`

  `python_version`

  :   A string defining the Python version to require. Passed to
      [`reticulate::py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html)

  `silent`

  :   Whether to suppress the message showing what has been required

## Value

An object representing a Python package

## Details

Python dependencies are set using
[`require_module()`](https://laminr.lamin.ai/reference/require_module.md)
before importing the module and used to create an ephemeral environment
unless another environment is found (see
[`vignette("versions", package = "reticulate")`](https://rstudio.github.io/reticulate/articles/versions.html)).

Requirements for the `lamindb` module can be controlled using
environment variables differently, see
<https://docs.lamin.ai/setup-laminr> for details.

## See also

- [`require_module()`](https://laminr.lamin.ai/reference/require_module.md)
  and
  [`reticulate::py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html)
  for defining Python dependencies

- [`vignette("versions", package = "reticulate")`](https://rstudio.github.io/reticulate/articles/versions.html)
  for setting the Python environment to use (or online
  [here](https://rstudio.github.io/reticulate/articles/versions.html))

## Examples

``` r
if (FALSE) { # \dontrun{
# Import lamindb to start interacting with an instance
ln <- import_module("lamindb")

# Import lamindb with optional dependencies
ln <- import_module("lamindb", options = c("bionty", "wetlab"))

# Import other LaminDB modules
bt <- import_module("bionty")
wl <- import_module("wetlab")
cc <- import_module("clinicore")

# Import any Python module
np <- import_module("numpy")
} # }
```
