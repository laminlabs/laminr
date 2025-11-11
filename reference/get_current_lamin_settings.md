# Get current LaminDB settings

Get the current LaminDB settings as an R list

## Usage

``` r
get_current_lamin_settings(minimal = FALSE)
```

## Arguments

- minimal:

  If `TRUE`, quickly extract a minimal list of important settings
  instead of converting the complete settings object

## Value

A list of the current LaminDB settings

## Details

This is done using
[`callr::r()`](https://callr.r-lib.org/reference/r.html) to avoid
importing Python `lamindb` in the global environment
