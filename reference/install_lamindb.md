# Install LaminDB

**\[deprecated\]**

This function is deprecated and is replaced by a system which
automatically installs packages as needed. See
[`import_module()`](https://laminr.lamin.ai/reference/import_module.md),
[`require_module()`](https://laminr.lamin.ai/reference/require_module.md)
and
[`reticulate::py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html)
for details.

Create a Python environment containing **lamindb** or install
**lamindb** into an existing environment.

## Usage

``` r
install_lamindb(
  ...,
  envname = "r-lamindb",
  extra_packages = NULL,
  new_env = identical(envname, "r-lamindb"),
  use = TRUE
)
```

## Arguments

- ...:

  Additional arguments passed to
  [`reticulate::py_install()`](https://rstudio.github.io/reticulate/reference/py_install.html)

- envname:

  String giving the name of the environment to install packages into

- extra_packages:

  A vector giving the names of additional Python packages to install

- new_env:

  Whether to remove any existing `virtualenv` with the same name before
  creating a new one with the requested packages

- use:

  Whether to attempt use the new environment

## Value

`NULL`, invisibly

## Examples

``` r
if (FALSE) { # \dontrun{
# Using import_module() will automatically install packages
ln <- import_module("lamindb")

# Create a Python environment with lamindb
# This approach is deprecated
install_lamindb()

# Add additional packages to the environment
install_lamindb(extra_packages = c("bionty", "pertdb"))

# Install into a different environment
install_lamindb(envvname = "your-env")
} # }
```
