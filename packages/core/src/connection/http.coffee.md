
# `nikita.connection.http`

Perform an HTTP request. It uses internaly the curl command.

## Options

* `cookies` (array)   
  Extra cookies to include in the request when sending HTTP to a server.
* `data` (string|any, ?optional)   
  The request HTTP body associated with "POST" and "PUT" requests. The
  `Accept: application/json` request header will be automatically inserted if
  not yet present and if `data` is not a string.
* `fail` (boolean, optional)   
  Fail silently (no output at all) on HTTP errors.
* `gid` (number|string, ?optional)   
  Group name or id who owns the target file; only apply if `target` is provided.
* `http_headers` (array)   
  Extra  header  to include in the request when sending HTTP to a server.
* `insecure` (boolean, optional)   
  Allow insecure server connections when using SSL; disabled if `cacert` is provided.
* `location` (boolean)   
  If the server reports that the requested page has moved to a different
  location (indicated with a Location: header and a 3XX response code), this
  option will make curl redo the request on the new place.
* `method` (string, optional, "GET")   
  Specify request command (HTTP method) to use.
* `mode` (octal mode)   
  Permissions of the target. If specified, nikita will chmod after download.
* `negotiate` (boolean, optional)   
  Use HTTP Negotiate (SPNEGO) authentication.
* `password` (string, ?optional)   
  Password associated with the Kerberos principal, required if `principal` is provided.
* `principal` (string, optional)   
  Kerberos principal name if a ticket must be generated along the `negociate` option.
* `proxy` (string)   
  Use the specified HTTP proxy. If the port number is not specified, it is
  assumed at port 1080. See curl(1) man page.
* `request` (string, optional, "GET")   
  Alias for `method` respecting the curl naming.
* `target` (path)   
  Write to file instead of stdout; mapped to the curl `output` argument.
* `uid` (number|string, ?optional)   
  User name or id who owns the target file; only apply if `target` is provided.
* `url` (string, required)   
  HTTP URL endpoint, must be a valid URL.

## Callback parameters

* `err` (Error)   
  Error object if any.
* `output.data` (string)   
  The decoded data is type is provided or detected.
* `output.body` (string)   
  The HTTP response body.
* `output.headers` ([string])   
  The HTTP response headers.
* `output.http_version` ([string])   
  The HTTP response http_version, eg 'HTTP/1.1'.
* `output.status_code` (string)   
  The HTTP response status code.
* `output.status_message` (string)   
  The HTTP response status message.
* `output.type` (string)   
  The format type if provided or detected, possible values is only "json" for now.

    module.exports = ({options}, callback) ->
      options.method ?= options.request
      options.method ?= 'GET'
      throw Error "Required Option: `url` is required, got #{options.url}" unless options.url
      throw Error "Required Option: `password` is required is principal is provided" if options.principal and not options.password
      throw Error "Required Option: `data` is required with POST and PUT requests" if options.method in ['POST', 'PUT'] and not options.data
      if options.data? and typeof options.data isnt 'string'
        options.http_headers['Accept'] ?= 'application/json'
        options.data = JSON.stringify options.data
      url_info = url.parse options.url
      options.http_headers ?= []
      options.cookies ?= []
      err = null
      output =
        body: []
        data: undefined
        http_version: undefined
        headers: {}
        status_code: undefined
        status_message: undefined
        type: undefined
      @system.execute
        cmd: """
        #{ unless options.principal then '' else [
          'echo', options.password, '|', 'kinit', options.principal
        ].join ' '}
        command -v curl >/dev/null || exit 3
        #{[
          'curl'
          '-i'
          '--fail' if options.fail
          '--insecure' if not options.cacert and url_info.protocol is 'https:'
          '--cacert #{options.cacert}' if options.cacert
          '--negotiate -u:' if options.negotiate
          '--location' if options.location
          ...("--header '#{header.replace '\'', '\\\''}:#{value.replace '\'', '\\\''}'" for header, value of options.http_headers)
          ...("--cookie '#{cookie.replace '\'', '\\\''}'" for cookie in options.cookies)
          "-o #{options.target}" if options.target
          "-x #{options.proxy}" if options.proxy
          "-X #{options.method}" if options.method isnt 'GET'
          "--data '#{options.data.replace '\'', '\\\''}'" if options.data
          "#{options.url}"
        ].join ' '}
        """
        trap: true
      , (_err, {code, stdout}) ->
        return err = Error "Required Dependencies: curl is required to perform HTTP requests" if _err and code is 3
        return err = _err if _err
        output.raw = stdout
        done_with_header = false
        for line, i in string.lines stdout
          if output.body.length is 0 and /^HTTP\/[\d.]+ \d+/.test line
            done_with_header = false
            output.headers = {}
            [http_version, status_code, status_message...] = line.split ' '
            output.http_version = http_version.substr 5
            output.status_code = parseInt status_code, 10
            output.status_message = status_message.join ' '
            just_finished_header = false
            continue
          else if line is ''
            done_with_header = true
            continue
          unless done_with_header
            [name, value...] = line.split ':'
            output.headers[name.trim()] = value.join(':').trim()
          else
            output.body.push line
      @call
        unless: -> !!err
      , ->
        @system.chmod
          if: options.target and options.mode
          mode: options.mode
        @system.chown
          if: options.target and options.uid? or options.gid?
          target: options.target
          uid: options.uid
          gid: options.gid
      @call ->
        return callback err if err
        output.type = 'json' if /^application\/json(;|$)/.test output.headers['Content-Type']
        output.body = output.body.join ''
        switch output.type
          when 'json' then output.data = JSON.parse output.body
        callback null, output

## Dependencies

    url = require 'url'
    string = require '../misc/string'
