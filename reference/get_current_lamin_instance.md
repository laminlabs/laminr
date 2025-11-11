# Get current LaminDB instance

Get the currently connected LaminDB instance

## Usage

``` r
get_current_lamin_instance()
```

## Value

The slug of the current LaminDB instance, or `NULL` invisibly if no
instance is found

## Details

This is done via a
[`get_current_lamin_settings()`](https://laminr.lamin.ai/reference/get_current_lamin_settings.md)
to avoid importing Python `lamindb`
