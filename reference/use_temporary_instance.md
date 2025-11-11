# Use a temporary LaminDB instance

Create and connect to a temporary LaminDB instance to use for the
current session. This function is primarily intended for developers to
use during testing and documentation but can also be useful for users to
debug issues or create reproducible examples.

## Usage

``` r
use_temporary_instance(
  name = "laminr-temp",
  modules = NULL,
  add_timestamp = TRUE,
  envir = parent.frame()
)
```

## Arguments

- name:

  A name for the temporary instance

- modules:

  A vector of modules to include (e.g. "bionty")

- add_timestamp:

  Whether to append a time stamp to `name` to make it unique

- envir:

  An environment passed to
  [`withr::defer()`](https://withr.r-lib.org/reference/defer.html)

## Details

This function creates and connects to a temporary LaminDB instance. A
temporary storage folder is created and used to initialize a new
instance. An exit handler is registered with
[`withr::defer()`](https://withr.r-lib.org/reference/defer.html) that
deletes the instance and storage, then reconnects to the previous
instance when `envir` finishes.

Switching to a temporary instance is not possible when another instance
is already connected.
