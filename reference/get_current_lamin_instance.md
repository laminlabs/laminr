# Get current LaminDB instance

Get the currently connected LaminDB instance

## Usage

``` r
get_current_lamin_instance(ignore_none = TRUE, silent = FALSE)
```

## Arguments

- ignore_none:

  Whether to ignore the `"none/none"` virtual instance as a valid
  instance and return `NULL`

- silent:

  Whether to suppress messages

## Value

The slug of the current LaminDB instance, or `NULL` invisibly if no
instance is found
