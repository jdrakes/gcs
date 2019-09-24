# Changelog

## v0.1.0
#### Features:
* Added more robust error handling for `gcs.ex` http requests
  * GCS errors are decoded from json if required and forwarded to user with format `{:gcs_error, status, error_message}`
#### BugFixes:
* `upload_object/4` uses the correct http method and GCS auth type
* `make_public/2` now adds the correct headers
#### Deprecations:
