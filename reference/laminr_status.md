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
#> ── laminr 1.3.0.9002 ───────────────────────────────────────────────────────────
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
#> ── Python 3.12.13 (main, Jun 23 2026, 15:18:55) [Clang 22.1.3 ] ──
#> 
#> ✔ lamindb v2.7.0
#> ✔ lamin_cli v1.18.2
#> ✔ lamin_utils v0.16.4
#> ✔ lamindb_setup v1.25.4
#> ✔ bionty v2.4.2
#> ✔ pertdb v2.2.0
#> ✖ wetlab
#> ✖ clinicore
#> ✖ cellregistry
#> ✖ omop
#> ✔ scipy v1.16.3
#> ✔ numpy v2.5.1
#> ✔ pandas v2.3.3
#> 
#> ℹ Run `reticulate::py_config()` and `reticulate::py_require()` for more
#>   information
```
