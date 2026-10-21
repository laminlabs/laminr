# laminr status

Overview of the current status of the laminr package and its
dependencies. Can be useful for debugging.

## Usage

``` r
laminr_status()
```

## Value

A `laminr_status` object

## Details

Provides information that can be useful for debugging. To run the
function when an error occurs, set
`options(error = function() { print(laminr::laminr_status() })`. Note
that this should be used with some caution as it will print the status
whenever any error occurs.

## Examples

``` r
laminr_status()
#> 
#> ── laminr 1.3.2.9000 ───────────────────────────────────────────────────────────
#> 
#> ── Environment Variables ──
#> 
#> `LAMINR_LAMINDB_VERSION`: "release"
#> 
#> ── Settings ──
#> 
#> User: "testuser1"
#> Instance: "laminlabs/lamindata"
#> 
#> ℹ To change the instance, use `ln <- import_module("lamindb"); ln$connect()`
#> ℹ Run `get_current_lamin_settings()` to see the full settings information
#> 
#> ── Python 3.13.16 (main, Oct 14 2026, 01:04:01) [Clang 23.1.3 ] ──
#> 
#> ✔ lamindb v2.12.0
#> ✔ lamin_cli v1.21.0
#> ✔ lamindb_setup v1.27.0
#> ✔ bionty v2.5.2
#> ✔ pertdb v2.2.1
#> ✖ wetlab
#> ✖ clinicore
#> ✖ cellregistry
#> ✖ omop
#> ✔ scipy v1.18.1
#> ✔ numpy v2.5.4
#> ✔ pandas v3.0.6
#> 
#> ℹ Run `reticulate::py_config()` and `reticulate::py_require()` for more
#>   information
```
