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
#> `LAMINR_LAMINDB_VERSION`: "devel"
#> 
#> ── Settings ──
#> 
#> User: "testuser1"
#> Instance: "laminlabs/lamindata"
#> 
#> ℹ To change the instance, use `ln <- import_module("lamindb"); ln$connect()`
#> ℹ Run `get_current_lamin_settings()` to see the full settings information
#> 
#> ── Python 3.13.18 (main, Oct 26 2026, 14:08:20) [Clang 23.1.3 ] ──
#> 
#> ✔ lamindb v2.12.1
#> ✔ lamin_cli v1.22.0
#> ✔ lamindb_setup v1.28.0
#> ✔ bionty v2.5.2
#> ✔ pertdb v2.2.1
#> ✖ wetlab
#> ✖ clinicore
#> ✖ cellregistry
#> ✖ omop
#> ✔ scipy v1.18.1
#> ✔ numpy v2.5.4
#> ✔ pandas v3.1.0
#> 
#> ℹ Run `reticulate::py_config()` and `reticulate::py_require()` for more
#>   information
```
