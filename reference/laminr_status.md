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
#> `LAMINR_LAMINDB_VERSION`: "release"
#> 
#> ── Settings ──
#> 
#> ✖ Not connected to an instance
#> 
#> ── Python 3.12.12 (main, Feb 12 2026, 00:42:14) [Clang 21.1.4 ] ──
#> 
#> ✔ lamindb v2.2.1
#> ✔ lamin_cli v1.14.1
#> ✔ lamin_utils v0.16.3
#> ✔ lamindb_setup v1.22.0
#> ✔ bionty v2.2.1
#> ✔ pertdb v2.1.1
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
