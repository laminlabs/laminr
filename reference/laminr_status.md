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
#> ── laminr 1.2.0.9001 ───────────────────────────────────────────────────────────
#> 
#> ── Environment Variables ──
#> 
#> `LAMINR_LAMINDB_VERSION`: "release"
#> `LAMINR_LAMINDB_OPTIONS`: "bionty"
#> 
#> ── Settings ──
#> 
#> ✖ Not connected to an instance
#> 
#> ── Python 3.12.12 (main, Oct 28 2025, 12:10:49) [Clang 20.1.4 ] ──
#> 
#> ✔ lamindb v1.15.2
#> ✔ lamin_cli v1.9.0
#> ✔ lamin_utils v0.15.0
#> ✔ lamindb_setup v1.15.0
#> ✔ bionty v1.8.1
#> ✔ wetlab v1.6.1
#> ✖ clinicore
#> ✖ cellregistry
#> ✖ omop
#> ✔ scipy v1.16.3
#> ✔ numpy v2.3.4
#> ✔ pandas v2.3.3
#> 
#> ℹ Run `reticulate::py_config()` and `reticulate::py_require()` for more
#>   information
```
