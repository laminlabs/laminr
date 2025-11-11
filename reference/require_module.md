# Require a Python module

This function can be used to require that Python modules are available
for laminr with additional checks and nicer error messages.

## Usage

``` r
require_module(
  module,
  options = NULL,
  version = NULL,
  source = NULL,
  python_version = NULL,
  silent = FALSE
)
```

## Arguments

- module:

  The name of the Python module to require

- options:

  A vector of defined optional dependencies for the module that is being
  required

- version:

  A string specifying the version of the module to require

- source:

  A source for the module requirement, for example
  `git+https://github.com/owner/module.git`

- python_version:

  A string defining the Python version to require. Passed to
  [`reticulate::py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html)

- silent:

  Whether to suppress the message showing what has been required

## Value

The result of
[reticulate::py_require](https://rstudio.github.io/reticulate/reference/py_require.html)

## Details

Python dependencies are set using
[`reticulate::py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html).
If a connection to Python is already initialized and the requested
module is already in the list of requirements then a further call to
[`reticulate::py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html)
will not be made to avoid errors/warnings. This means that required
versions etc. need to be set before Python is initialized.

### Arguments

- Setting `options = c("opt1", "opt2")` results in `"module[opt1,opt2]"`

- Setting `version = ">=1.0.0"` results in `"module>=1.0.0"`

- Setting `source = "my_source"` results in `"module @ my_source"`

- Setting all of the above results in
  `"module[opt1,opt2]>=1.0.0 @ my_source"`

## See also

[`reticulate::py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html)

## Examples

``` r
if (FALSE) { # \dontrun{
# Require lamindb
require_module("lamindb")

# Require a specific version of lamindb
require_module("lamindb", version = ">=1.2")

# Require require lamindb with options
require_module("lamindb", options = c("bionty", "wetlab"))

# Require the development version of lamindb from GitHub
require_module("lamindb", source = "git+https://github.com/laminlabs/lamindb.git")

# Require lamindb with a specific Python version
require_module("lamindb", python_version = "3.12")
} # }
```
