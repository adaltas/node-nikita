
# `nikita.network.http`

Perform an HTTP request. It uses internaly the curl command.

## Return

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

## Hooks

    on_action = ({config}) ->
      config.method ?= config.request

## Schema

    schema =
      type: 'object'
      properties:
        cookies:
          type: 'array'
          items:
            type: 'string'
          description: """
          Extra cookies to include in the request when sending HTTP to a server.
          """
        data:
          type: ['array', 'boolean', 'null', 'number', 'object', 'string']
          description: """
          The request HTTP body associated with "POST" and "PUT" requests. The
          `Accept: application/json` request header will be automatically
          inserted if not yet present and if `data` is not a string.
          """
        fail:
          type: 'boolean'
          description: """
          Fail silently (no output at all) on HTTP errors.
          """
        gid:
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chown#/properties/gid'
          description: """
          Group name or id who owns the target file; only apply if `target` is provided.
          """
        http_headers:
          type: 'object'
          default: {}
          description: """
          Extra header to include in the request when sending the HTTP request
          to a server.
          """
        insecure:
          type: 'boolean'
          description: """
          Allow insecure server connections when using SSL; disabled if `cacert` is provided.
          """
        location:
          type: 'boolean'
          description: """
          If the server reports that the requested page has moved to a different
          location (indicated with a Location: header and a 3XX response code), this
          option will make curl redo the request on the new place.
          """
        method:
          type: 'string'
          default: 'GET'
          description: """
          Specify request command (HTTP method) to use.
          """
        mode:
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chmod#/properties/mode'
          description: """
          Permissions of the target. If specified, nikita will chmod after
          download.
          """
        negotiate:
          type: 'boolean'
          description: """
          Use HTTP Negotiate (SPNEGO) authentication.
          """
        proxy:
          type: 'string'
          description: """
          Use the specified HTTP proxy. If the port number is not specified, it
          is assumed at port 1080. See curl(1) man page.
          """
        password:
          type: 'string'
          description: """
          Password associated with the Kerberos principal, required if
          `principal` is provided.
          """
        principal:
          type: 'string'
          description: """
          Kerberos principal name if a ticket must be generated along the
          `negociate` option.
          """
        referer:
          type: 'string'
          description: """
          An alias for connection.http_headers[\'Referer\']
          """
        request:
          $ref: '#/properties/method'
          description: """
          Alias for `method` respecting the curl naming.
          """
        target:
          type: 'string'
          description: """
          Write to file instead of stdout; mapped to the curl `output` argument.
          """
        uid:
          $ref: 'module://@nikitajs/engine/src/actions/fs/base/chown#/properties/uid'
          description: """
          User name or id who owns the target file; only apply if `target` is
          provided.
          """
        url:
          type: 'string'
          description: """
          HTTP URL endpoint, must be a valid URL.
          """
      required: ['url']

## Handler

    handler = ({config}) ->
      throw Error "Required Option: `password` is required if principal is provided" if config.principal and not config.password
      throw Error "Required Option: `data` is required with POST and PUT requests" if config.method in ['POST', 'PUT'] and not config.data
      if config.data? and typeof config.data isnt 'string'
        config.http_headers['Accept'] ?= 'application/json'
        config.http_headers['Content-Type'] ?= 'application/json'
        config.data = JSON.stringify config.data
      url_info = url.parse config.url
      config.http_headers ?= []
      config.cookies ?= []
      err = null
      output =
        body: []
        data: undefined
        http_version: undefined
        headers: {}
        status_code: undefined
        status_message: undefined
        type: undefined
      try
        {code, stdout} = await @execute
          cmd: """
          #{ unless config.principal then '' else [
            'echo', config.password, '|', 'kinit', config.principal, '>/dev/null'
          ].join ' '}
          command -v curl >/dev/null || exit 3
          #{[
            'curl'
            '--include' # Include protocol headers in the output (H/F)
            '--silent' # Dont print progression to stderr
            '--fail' if config.fail
            '--insecure' if not config.cacert and url_info.protocol is 'https:'
            '--cacert #{config.cacert}' if config.cacert
            '--negotiate -u:' if config.negotiate
            '--location' if config.location
            ...("--header '#{header.replace '\'', '\\\''}:#{value.replace '\'', '\\\''}'" for header, value of config.http_headers)
            ...("--cookie '#{cookie.replace '\'', '\\\''}'" for cookie in config.cookies)
            "-o #{config.target}" if config.target
            "-x #{config.proxy}" if config.proxy
            "-X #{config.method}" if config.method isnt 'GET'
            "--data #{utils.string.escapeshellarg config.data}" if config.data
            "#{config.url}"
          ].join ' '}
          """
          trap: true
        output.raw = stdout
        done_with_header = false
        for line, i in utils.string.lines stdout
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
      catch err
        throw Error "Required Dependencies: curl is required to perform HTTP requests" if err.exit_code is 3
        throw err
      @fs.chmod
        if: config.target and config.mode
        mode: config.mode
      @fs.chown
        if: config.target and config.uid? or config.gid?
        target: config.target
        uid: config.uid
        gid: config.gid
      output.type = 'json' if /^application\/json(;|$)/.test output.headers['Content-Type']
      output.body = output.body.join ''
      switch output.type
        when 'json' then output.data = JSON.parse output.body
      output

# Export

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema

## Dependencies

    url = require 'url'
    utils = require '@nikitajs/engine/lib/utils'
