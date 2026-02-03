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
#> ── laminr 1.2.2.9005 ───────────────────────────────────────────────────────────
#> 
#> ── Environment Variables ──
#> 
#> `LAMINR_LAMINDB_VERSION`: "devel"
#> 
#> ── Settings ──
#> 
#> ✖ Not connected to an instance
#> 
#> ── Python 3.12.12 (main, Jan 27 2026, 23:58:14) [Clang 21.1.4 ] ──
#> 
#> ✔ lamindb v2.1.0
#> ✔ lamin_cli v1.12.0
#> ✔ lamin_utils v0.16.3
#> ✔ lamindb_setup v1.19.0
#> ✔ bionty v2.1.0
#> ✔ pertdb v2.0.2
#> ✔ wetlab v2.0.1
#> ✖ clinicore
#> ✖ cellregistry
#> ✖ omop
#> ✔ scipy v1.16.3
#> ✔ numpy v2.4.2
#> ✔ pandas v2.3.3
#> 
#> ℹ Run `reticulate::py_config()` and `reticulate::py_require()` for more
#>   information
```
