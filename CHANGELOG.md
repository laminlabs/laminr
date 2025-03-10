# laminr v1.0.0

LaminR now has feature parity with LaminDB (PR #146).

Migration guide:

- Run `install_lamindb()`, which will ensure `lamindb >= 1.2` in the Python environment used by `reticulate`.
- Replace `db <- connect()` with `ln <- import_module("lamindb")` and see the table below. The `ln` object is largely similar to the `db` object in **{laminr}** < v1 and matches `lamindb`'s Python API up to replacing `.` with `$`.

| What | Before | After |
|--------|--------|--------|
| Connect to the default LaminDB instance | `db <- connect()` | `ln <- import_module("lamindb")` |
| Start tracking | `db$track()` | `ln$track()` |
| Get an artifact from another instance | `new_instance <- connect("another/instance"); new_instance$Artifact$get(...)` | `ln$Artifact$using("another/instance")$get(...)` |
| Create an artifact from a path | `db$Artifact$from_path(path)` | `ln$Artifact(path)` | 
| Finish tracking | `db$finish()` | `ln$finish()` |

See the updated ["Get started"](https://laminr.lamin.ai/articles/laminr.html) vignette for more information.

User-facing changes:

  - Add an `import_module()` function to import Python modules with additional functionality, e.g., `import_module("lamindb")` for **lamindb**
  - Add functions for accessing more `lamin` CLI commands
  - Add a new "Introduction" vignette that replicates the code from the Python **lamindb** introduction guide

Internal changes:

  - Add an internal `wrap_python()` function to wrap Python objects while replacing Python methods with R methods as needed, leaving most work to **{reticulate}**
  - Update the internal `check_requires()` function to handle Python packages
  - Add custom `cache()`/`load()` methods to the `Artifact` class
  - Add custom `track()`/`finish()` methods to the **lamindb** module

# laminr v0.4.1

## MINOR CHANGES

- Bump R dependency to >= 4.1.0 to fix note on CRAN (PR #142).

# laminr v0.4.0

Minor (breaking) changes to support the Python `lamindb` v1.0 release.

## BREAKING CHANGES

- Updates for compatibility with the Python `lamindb` v1.0 release (PR #136)

## MINOR CHANGES

- `db$track()` can now automatically create a transform UID when not supplied (PR #136)

# laminr v0.3.1

This release improves the UX for setting up the Python environment and adds functions to allow access to CLI functionality from R.

## NEW FUNCTIONALITY

- Add a `install_lamindb()` function to help with setting up the default Python environment (PR #129).
- Add `lamin_login()` and `lamin_connect()` functions to allow access to CLI functionality from R (PR #129).

## DOCUMENTATION

- Add a set up vignette and update other documentation with instructions for how to set up a Python environment (PR #129).


# laminr v0.3.0

This release contains mostly UX improvements:

- Support for interacting with private LaminDB instances
- Support for interacting with TileDB-SOMA / CELLxGENE Census
- Improved UX for tracking and finishing runs

## NEW FUNCTIONALITY

- Allow tracking of artifacts loaded for non-default instances (PR #124).
- Interact with TileDB-SOMA stores (PR #117). Add a `open()` method to the `Artifact` class to connect to TileDB-SOMA stores.

## MINOR CHANGES

- Improve UX of `db$track()` and `db$finish()` (PR #120).

## BUG FIXES

- Allow connecting to private LaminDB instances (PR #118).
- Fix error message when fetching the instance details fails (PR #123).

## TESTING

- Use the host system user for tests (PR #119)

## DOCUMENTATION

- Update the laminr Getting Started vignette with feedback from demo (PR #113).
- Update roadmap (PR #112).
- Simplify `README` content (PR #116).

# laminr v0.2.0

This release adds support for creating new artifacts in a LaminDB instance.

## NEW FUNCTIONALITY

- Add support for more loaders (PR #81).  
  Currently supported: `.csv`, `.h5ad`, `.html`, `.jpg`, `.json`, `.parquet`, `.png`, `.rds`, `.svg`, `.tsv`, `.yaml`.  
- Add a `from_df()` method to the `Registry` class to create new artifacts from data frames (PR #78)
- Create `TemporaryRecord` classes for new artifacts before they have been saved to the database (PR #78)
- Add a `delete()` method to the `Record` class (PR #78)
- Add `track()` and `finish()` methods to the `Instance` class (PR #83)
- Add a `from_path()` method to the `Registry` class to create new artifacts from paths (PR #85)
- Add a `from_anndata()` method to the `Registry` class to create new artifacts from `AnnData` objects (PR #85)
- Add RStudio add-in for saving a notebook (PR #90).

## MAJOR CHANGES

- Running `connect(slug = NULL)` now connects to the default instance that is allowed to create records.
  The default instance must be changed using the Lamin CLI. (PR #78)
- User setting are stored in a global option the first time `connect()` is run (PR #78)

## MINOR CHANGES

- Adjusted argument order in `Instance$track()` and improved Python error handling (PR #89)

## TESTING

- Add a test for creating artifacts from data frames (PR #78).
- Add tests for creating artifacts from paths and `AnnData` objects (PR #85)

## DOCUMENTATION

- Updated installation instructions after **{laminr}** was released on CRAN (PR #74).
- Updated the architecture vignette to include new methods and the new `TemporaryRecord` class (PR #78, PR #83, PR #85)
- Updated the development vignette with new functionality (PR #78, PR #83, PR #85)

# laminr v0.1.0

First CRAN release of the LaminDB API client for R. This release focuses on connecting to a LaminDB instance, fetching an individual record from the instance, and fetching related data for that record.

Features:

- Connect to a LaminDB instance
- Auto-generate modules and classes from the instance schema
- Fetch a record
- Fetch a record's related data
- Fetch record summary table
- Cache S3 artifact
- Load AnnData artifact

For more information, please visit the [package website](https://laminr.lamin.ai).

## NEW FUNCTIONALITY

- Query instance settings from Lamin Hub (PR #8).
- Read user settings from env file created by lamin Python package (PR #2, PR #8).
- Add `to_string()` and `print()` methods to the `Record` class and (incomplete) `describe()` method to the `Artifact()` class (PR #22).
- Add `to_string()` and `print()` methods to remaining classes (PR #31)
- Add `InstanceAPI$get_records()` and `Registry$df()` methods (PR #54)
- Add a `RelatedRecords` class and `RelatedRecords$df()` method (PR #59)

## MAJOR CHANGES

- Refactored the internal class data structures for better modularity and extensibility (PR #8).
- Added GitHub actions to the project (PR #11):

  - Standard R-CMD-check workflow.
  - Linting action.
  - Commands for roxygenizing (`/document`) and restyling the source code (`/style`).

- Allow unauthenticated users to connect to an instance if they ran `lamin connect <instance>` beforehand (PR #19).

## MINOR CHANGES

- Do not complain when foreign keys are not found in a record, but also do not complain when they are (PR #13).
- Define a current user and current instance with lamin-cli prior to testing and generating documentation in the CI (PR #23).
- Add progress bars to `Artifact$cache()` (PR #58)
- Remove link tables from object print output (PR #55)
- Improve checking for suggested packages and provide installation instructions if missing (PR #56)
- Add the status code to API error messages (PR #70)
- Adjust colours in print output (PR #69)
- Modify `Registry` print output to separate relational fields by module (PR #71)

## TESTING

- Add a simple unit test which queries laminlabs/lamindata (PR #27).
- Added unit test for the InstanceAPI class (PR #30).
- Add a regular expression to the API test for missing records (PR #70)

## DOCUMENTATION

- Update `README` with new set up instructions and simplify (PR #14).
- Add a `pkgdown` website to the project (PR #13).
- Further simplify the `README`, and move the detailed usage description to a separate vignette (PR #13).
- Generate vignettes using Quarto (PR #13).
- Add vignette to showcase laminr usage (PR #18).
- Replace all mentions of `lamin load` with `lamin connect` (PR #29).
- Improve the `README` (PR #29).
- Set Python requirements to `lamindb[aws]` for now (PR #33). Will be changed to `lamin_cli` once
  [laminlabs/lamin-cli#90](https://github.com/laminlabs/lamin-cli/issues/90) is solved.
- Improve documentation for installing suggested dependencies and what they are required for (PR #56).
- Update the README to give a better overview of the package (PR #67).
- Rename the `usage` vignette to `laminr` and added an overview of the core concepts of LaminDB (PR #67).
- Update the `architecture` vignette to relate the class structure of the package to the core concepts (PR #67).
- Add a `development` vignette to document the list of current, planned and unplanned functionality (PR #67).
- Add vignettes to document registries in the core, bionty, and wetlab modules (PR #67).

## BUG FIXES

- Fixed the parsing of the env files in `~/.lamin` due to changes in the lamindb-setup Python package (PR #12).
- Return `NULL` when a record's related field is empty (PR #28).
- Add alternative error message when no message is returned from the API (PR #30).
- Handle when error detail returned by the API is a list (PR #59)
- Manually install OpenBLAS on macOS (PR #62).
- Switch to Python 3.12 for being able to install scipy on macOS (PR #66).

# laminr v0.0.1

Initial POC implementation of the LaminDB API client for R.

Functionality:

- Connect to a LaminDB instance
- Fetch instance schema
- Auto-generate classes from schema
- See available modules and classes
- Get a record
- Get a record's related data
- Cache S3 artifact
- Load AnnData artifact
