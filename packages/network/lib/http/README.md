
# `nikita.network.http`

Perform an HTTP request. Internaly, the action requires the presence of the
`curl` command.

## Return

* `data` (string)   
  The decoded data is type is provided or detected.
* `body` (string)   
  The HTTP response body.
* `headers` ([string])   
  The HTTP response headers.
* `http_version` ([string])   
  The HTTP response http_version, eg 'HTTP/1.1'.
* `status_code` (string)   
  The HTTP response status code.
* `status_message` (string)   
  The HTTP response status message.
* `type` (string)   
  The format type if provided or detected, possible values is only "json" for now.

## Error

The `error.code` reflects the native `curl` errors code. You can get a list of
them with `man 3 libcurl-errors`. For example:

```js
try {
  await nikita.network.http({
    url: "http://2222:localhost"
  })
} catch (err) {
  assert(err.code, 'CURLE_URL_MALFORMAT')
  assert(err.message, 'CURLE_URL_MALFORMAT: the curl command exited with code `3`.')
}
```
