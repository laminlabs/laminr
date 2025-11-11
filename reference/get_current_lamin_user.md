# Get current LaminDB user

Get the currently logged in LaminDB user

## Usage

``` r
get_current_lamin_user()
```

## Value

The handle of the current LaminDB user, or `NULL` invisibly if no user
is found

## Details

This is done via
[`get_current_lamin_settings()`](https://laminr.lamin.ai/reference/get_current_lamin_settings.md)
to avoid importing Python `lamindb`
