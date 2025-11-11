# Lamin CLI functions

**\[deprecated\]**

Lamin CLI calls are available from R by importing the **lamin_cli**
Python module using `lc <- import_module("lamin_cli")`. The previous CLI
functions are now deprecated, see examples for how to switch to the new
syntax.

## Usage

``` r
# Import the module instead of using deprecated functions
# lc <- import_module("lamin_cli")

# Deprecated functions

lamin_connect(instance)

lamin_disconnect()

lamin_login(user = NULL, api_key = NULL)

lamin_logout()

lamin_init(storage, name = NULL, db = NULL, modules = NULL)

lamin_init_temp(
  name = "laminr-temp",
  db = NULL,
  modules = NULL,
  add_timestamp = TRUE,
  envir = parent.frame()
)

lamin_delete(instance, force = FALSE)

lamin_save(filepath, key = NULL, description = NULL, registry = NULL)

lamin_settings()
```

## Arguments

- instance:

  Either a slug giving the instance to connect to (`<owner>/<name>`) or
  an instance URL (`https://lamin.ai/owner/name`). For `lamin_delete()`,
  the slug for the instance to delete.

- user:

  Handle for the user to login as

- api_key:

  API key for a user

- storage:

  A local directory, AWS S3 bucket or Google Cloud Storage bucket

- name:

  A name for the instance

- db:

  A Postgres database connection URL, use `NULL` for SQLite

- modules:

  A vector of modules to include (e.g. "bionty")

- add_timestamp:

  Whether to append a timestamp to `name` to make it unique

- envir:

  An environment passed to
  [`withr::defer()`](https://withr.r-lib.org/reference/defer.html)

- force:

  Whether to force deletion without asking for confirmation

- filepath:

  Path to the file or folder to save

- key:

  The key for the saved item

- description:

  The description for the saved item

- registry:

  The registry for the saved item

## Details

### `lamin_connect()`

Running this will set the LaminDB auto-connect option to `True` so you
auto-connect to `instance` when importing Python `lamindb`.

### `lamin_login()`

Depending on the input, one of these commands will be run (in this
order):

1.  If `user` is set then `lamin login <user>`

2.  Else if `api_key` is set then set the `LAMIN_API_KEY` environment
    variable temporarily with
    [`withr::with_envvar()`](https://withr.r-lib.org/reference/with_envvar.html)
    and run `lamin login`

3.  Else if there is a stored user handle run `lamin login <handle>`

4.  Else if the `LAMIN_API_KEY` environment variable is set run
    `lamin login`

Otherwise, exit with an error

### `lamin_init_temp()`

For `lamin_init_temp()`, a time stamp is appended to `name` (if
`add_timestamp = TRUE`) and then a new instance is initialised with
`lamin_init()` using a temporary directory. A `lamin_delete()` call is
registered as an exit handler with
[`withr::defer()`](https://withr.r-lib.org/reference/defer.html) to
clean up the instance when `envir` finishes.

The `lamin_init_temp()` function is mostly for internal use and in most
cases users will want `lamin_init()`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Import Lamin modules
lc <- import_module("lamin_cli")
ln <- import_module("lamindb")

# Examples of replacing CLI functions with the lamin_cli module
} # }
if (FALSE) { # \dontrun{
# Connect to a LaminDB instance
lamin_connect(instance)
# ->
lc$connect(instance)
} # }
if (FALSE) { # \dontrun{
# Disconnect from a LaminDB instance
lamin_disconnect()
# ->
lc$disconnect()
} # }
if (FALSE) { # \dontrun{
# Log in as a LaminDB user
lamin_login(...)
# ->
lc$login(...)
} # }
if (FALSE) { # \dontrun{
# Log out of LaminDB
lamin_logout()
# ->
lc$logout()
} # }
if (FALSE) { # \dontrun{
# Create a new LaminDB instance
lamin_init(...)
# ->
lc$init(...)
} # }
if (FALSE) { # \dontrun{
# Create a temporary LaminDB instance
lamin_init_temp(...)
# ->
create_temporary_instance()
} # }
if (FALSE) { # \dontrun{
# Delete a LaminDB entity
lamin_delete(...)
# ->
lc$delete(...)
} # }
if (FALSE) { # \dontrun{
# Save to a LaminDB instance
lamin_save(...)
# ->
lc$save(...)
} # }
if (FALSE) { # \dontrun{
# Access Lamin settings
lamin_settings()
# ->
ln$setup$settings
# OR
ln$settings
# Alternatively
get_current_lamin_settings()
} # }
```
