# laminr v0.1.0

## NEW FUNCTIONALITY

* Query instance settings from Lamin Hub (PR #8).

* Read user settings from env file created by lamin Python package (PR #2, PR #8).

* Add `to_string()` and `print()` methods to the `Record` class and (incomplete) `describe()` method to the `Artifact()` class (PR #22).

## MAJOR CHANGES

* Refactored the internal class data structures for better modularity and extensibility (PR #8).

* Added GitHub actions to the project (PR #11):
  - Standard R-CMD-check workflow.
  - Linting action.
  - Commands for roxygenizing (`/document`) and restyling the source code (`/style`).

* Allow unauthenticated users to connect to an instance if they ran `lamin connect <instance>` beforehand (PR #19).

## MINOR CHANGES

* Do not complain when foreign keys are not found in a record, but also do not complain when they are (PR #13).

* Define a current user and current instance with lamin-cli prior to testing and generating documentation in the CI (PR #23).

* Add a simple unit test which queries laminlabs/lamindata (PR #27).

## DOCUMENTATION

* Update `README` with new set up instructions and simplify (PR #14).

* Add a `pkgdown` website to the project (PR #13).

* Further simplify the `README`, and move the detailed usage description to a separate vignette (PR #13).

* Generate vignettes using Quarto (PR #13).

* Add vignette to showcase laminr usage (PR #18).

* Replace all mentions of `lamin load` with `lamin connect` (PR #29).

* Improve the `README` (PR #29).

## BUG FIXES

* Fixed the parsing of the env files in `~/.lamin` due to changes in the lamindb-setup Python package (PR #12).

# laminr v0.0.1

Initial POC implementation of the LaminDB API client for R.

Functionality:

* Connect to a LaminDB instance
* Fetch instance schema
* Auto-generate classes from schema
* See available modules and classes
* Get a record
* Get a record's related data
* Cache S3 artifact
* Load AnnData artifact
