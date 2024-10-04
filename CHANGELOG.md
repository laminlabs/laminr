# laminr v0.1.0

## NEW FUNCTIONALITY

* Query instance settings from Lamin Hub (PR #8).

* Read user settings from env file created by lamin Python package (PR #2, PR #8).

## MAJOR CHANGES

* Refactored the internal class data structures for better modularity and extensibility (PR #8).

* Added GitHub actions to the project (PR #11):
  - Standard R-CMD-check workflow.
  - Linting action.
  - Commands for roxygenizing (`/document`) and restyling the source code (`/style`).

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
