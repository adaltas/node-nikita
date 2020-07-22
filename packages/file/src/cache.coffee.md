
# `nikita.file.cache`

Download a file and place it on a local or remote folder for later usage.

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if cache file was created or modified.   

## HTTP example

Cache can be used from the `file.download` action:

```js
require('nikita')
.file.download({
  source: 'https://github.com/wdavidw/node-nikita/tarball/v0.0.1',
  cache_dir: '/var/tmp'
}, function(err, {status}){
  console.info(err ? err.message : 'File downloaded: ' + status);
});
```

## On config

    on_action = ({config, metadata}) ->
      # Options
      config.source = metadata.argument if metadata.argument?
      throw Error "Missing source: '#{config.source}'" unless config.source
      throw Error "Missing one of 'target', 'cache_file' or 'cache_dir' option" unless config.cache_file or config.target or config.cache_dir
      config.target ?= config.cache_file
      config.target ?= path.basename config.source
      config.target = path.resolve config.cache_dir, config.target
      config.source = config.source.substr 7 if /^file:\/\//.test config.source
      config.http_headers ?= []
      config.cookies ?= []

## Schema

    schema =
      type: 'object'
      properties:
        'cache_dir':
          type: 'string'
          description: """
          Path of the cache directory.
          """
        'cache_file':
          oneOf:[{type: 'string'}, {typeof: 'boolean'}]
          description: """
          Alias for 'target'.
          """
        'cache_local':
          type: 'boolean'
          description: """
          Apply to SSH mode, treat the cache file and directories as local from where
          the command is used instead of over SSH.
          """
        'cookies':
          type: 'array', items: type: 'string'
          description: """
          Extra cookies  to include in the request when sending HTTP to a server.
          """
        'fail':
          type: 'boolean'
          description: """
          Send an error if the HTTP response code is invalid. Similar to the curl
          option of the same name.
          """
        'force':
          type: 'boolean'
          description: """
          Overwrite the target file if it exists, bypass md5 verification.
          """
        'http_headers':
          type: 'array', items: type: 'string'
          description: """
          Extra header to include in the request when sending HTTP to a server.
          """
        'location':
          type: 'boolean'
          description: """
          If the server reports that the requested page has moved to a different
          location (indicated with a Location: header and a 3XX response code), this
          option will make curl redo the request on the new place.
          """
        'proxy':
          type: 'string'
          description: """
          Use the specified HTTP proxy. If the port number is not specified, it is
          assumed at port 1080. See curl(1) man page.
          """
        'source':
          type: 'string'
          description: """
          File, HTTP URL, FTP, GIT repository. File is the default protocol if source
          is provided without any.
          """
        'target':
          oneOf:[{type: 'string'}, {typeof: 'boolean'}]
          description: """
          Cache the file on the executing machine, equivalent to cache unless an ssh
          connection is provided. If a string is provided, it will be the cache path.
          Default to the basename of source.
          """

## Handler

    handler = ({config, log, metadata, operations: {status, events}, ssh}) ->
      log message: "Entering file.cache", level: 'DEBUG', module: 'nikita/lib/file/cache'
      # SSH connection
      ssh = @ssh config.ssh
      # todo, also support config.algo and config.hash
      if config.md5?
        throw Error "Invalid MD5 Hash:#{config.md5}" unless typeof config.md5 in ['string', 'boolean']
        algo = 'md5'
        _hash = config.md5
      else if config.sha1?
        throw Error "Invalid SHA-1 Hash:#{config.sha1}" unless typeof config.sha1 in ['string', 'boolean']
        algo = 'sha1'
        _hash = config.sha1
      else if config.sha256?
        throw Error "Invalid SHA-1 Hash:#{config.sha256}" unless typeof config.sha256 in ['string', 'boolean']
        algo = 'sha256'
        _hash = config.sha256
      else
        algo = 'md5'
        _hash = false
      u = url.parse config.source
      @call ->
        unless u.protocol is null
          log message: "Bypass source hash computation for non-file protocols", level: 'WARN', module: 'nikita/lib/file/cache'
          return
        return if _hash isnt true
        _hash = await @fs.hash config.source
        _hash = if _hash?.hash then _hash.hash else false
        log message: "Computed hash value is '#{_hash}'", level: 'INFO', module: 'nikita/lib/file/cache'
      # Download the file if
      # - file doesnt exist
      # - option force is provided
      # - hash isnt true and doesnt match
      {status} = await @call ->
        log message: "Check if target (#{config.target}) exists", level: 'DEBUG', module: 'nikita/lib/file/cache'
        exists = await @fs.base.exists target: config.target
        if exists
          log message: "Target file exists", level: 'INFO', module: 'nikita/lib/file/cache'
          # If no checksum , we ignore MD5 check
          if config.force
            log message: "Force mode, cache will be overwritten", level: 'DEBUG', module: 'nikita/lib/file/cache'
            return true
          else if _hash and typeof _hash is 'string'
            # then we compute the checksum of the file
            log message: "Comparing #{algo} hash", level: 'DEBUG', module: 'nikita/lib/file/cache'
            {hash} = await @fs.hash config.target
            # And compare with the checksum provided by the user
            if _hash is hash
              log message: "Hashes match, skipping", level: 'DEBUG', module: 'nikita/lib/file/cache'
              return false
            log message: "Hashes don't match, delete then re-download", level: 'WARN', module: 'nikita/lib/file/cache'
            @fs.base.unlink target: config.target
            true
          else
            log message: "Target file exists, check disabled, skipping", level: 'DEBUG', module: 'nikita/lib/file/cache'
            false
        else
          log message: "Target file does not exists", level: 'INFO', module: 'nikita/lib/file/cache'
          true
      return status unless status
      # Place into cache
      if u.protocol in protocols_http
        @fs.mkdir
          ssh: if config.cache_local then false else config.ssh
          target: path.dirname config.target
        await @execute
          cmd: [
            'curl'
            '--fail' if config.fail
            '--insecure' if u.protocol is 'https:'
            '--location' if config.location
            ...("--header '#{header.replace '\'', '\\\''}'" for header in config.http_headers)
            ...("--cookie '#{cookie.replace '\'', '\\\''}'" for cookie in config.cookies)
            "-s #{config.source}"
            "-o #{config.target}"
            "-x #{config.proxy}" if config.proxy
          ].join ' '
          ssh: if config.cache_local then false else config.ssh
          unless_exists: config.target
      else
        @fs.mkdir # todo: copy shall handle this
          target: "#{path.dirname config.target}"
        @fs.copy
          source: "#{config.source}"
          target: "#{config.target}"
      # Validate the cache
      {hash} = await @fs.hash
        target: config.target
        if: _hash
      hash ?= false
      throw Error "Invalid Target Hash: target #{JSON.stringify config.target} got #{hash} instead of #{_hash}" unless _hash is hash

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      schema: schema
    module.exports.protocols_http = protocols_http = ['http:', 'https:']
    module.exports.protocols_ftp = protocols_ftp = ['ftp:', 'ftps:']

## Dependencies

    path = require 'path'
    url = require 'url'
    curl = require '@nikitajs/engine/src/utils/curl'
