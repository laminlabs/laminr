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
#> ── laminr 1.2.2.9000 ───────────────────────────────────────────────────────────
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
#> ── Python 3.12.12 (main, Jan 27 2026, 23:58:14) [Clang 21.1.4 ] ──
#> 
#> ✔ lamindb v2.0.1
#> ✔ lamin_cli v1.11.0
#> ✔ lamin_utils v0.16.2
#> ✔ lamindb_setup v1.18.1
#> ✔ bionty v2.0.0
#> ✖ wetlab
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
