
# `mecano.cache(options, [callback])`

Download a file and place it on a local or remote folder for later usage.

## Options

*   `cache_dir` (path)
    If local_cache is not a string, the cache file path is resolved from cache dir and cache file.
    By default: './'
*   `cache_file` (string | boolean)
    Alias for "target".
*   `cache_local` (boolean)
    Apply to SSH mode, treat the cache file and directories as local from where
    the command is used instead of over SSH.
*   `fail` (boolean)
    Send an error if the HTTP response code is invalid. Similar to the curl
    option of the same name.
*   `force` (boolean)
    Overwrite the target file if it exists, bypass md5 verification.
*   `headers` (array)
    Extra header  to include in the request when sending HTTP to a server.
*   `location` (boolean)
    If the server reports that the requested page has moved to a different
    location (indicated with a Location: header and a 3XX response code), this
    option will make curl redo the request on the new place.
*   `proxy` (string)
    Use the specified HTTP proxy. If the port number is not specified, it is
    assumed at port 1080. See curl(1) man page.
*   `source` (path)
    File, HTTP URL, FTP, GIT repository. File is the default protocol if source
    is provided without any.
*   `target` (string | boolean)
    Cache the file on the executing machine, equivalent to cache unless an ssh
    connection is provided. If a string is provided, it will be the cache path.
    Default to the basename of source.

## Callback Parameters

*   `err`
    Error object if any.
*   `status`
    Value is "true" if cache file was created or modified.

## HTTP example

```js
require('mecano').download({
  source: 'https://github.com/wdavidw/node-mecano/tarball/v0.0.1',
  cache_dir: '/var/tmp'
}, function(err, status){
  console.log(err ? err.message : 'File downloaded: ' + status);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering cache", level: 'DEBUG', module: 'mecano/lib/cache'
      options.source = options.argument if options.argument?
      return callback Error "Missing source: '#{options.source}'" unless options.source
      return callback Error "Missing one of 'target', 'cache_file' or 'cache_dir' option" unless options.cache_file or options.target or options.cache_dir
      options.target ?= options.cache_file
      options.target ?= path.basename options.source
      options.target = path.resolve options.cache_dir, options.target
      options.source = options.source.substr 7 if /^file:\/\//.test options.source
      options.headers ?= []
      if options.md5?
        return callback new Error "Invalid MD5 Hash:#{options.md5}" unless typeof options.md5 in ['string', 'boolean']
        algo = 'md5'
        hash = options.md5
      else if options.sha1?
        return callback new Error "Invalid SHA-1 Hash:#{options.sha1}" unless typeof options.sha1 in ['string', 'boolean']
        algo = 'sha1'
        hash = options.sha1
      else
        algo = 'md5'
        hash = false
      u = url.parse options.source
      @call
        handler: (_, callback) ->
          unless u.protocol is null
            options.log message: "Bypass source hash computation for non-file protocols", level: 'WARN', module: 'mecano/lib/cache'
            return callback()
          return callback() if hash isnt true
          file.hash options.ssh, options.source, algo, (err, value) ->
            return callback err if err
            options.log message: "Computed hash value is '#{value}'", level: 'INFO', module: 'mecano/lib/cache'
            hash = value
            callback()
      # Download the file if
      # - file doesnt exist
      # - option force is provided
      # - hash isnt true and doesnt match
      @call
        shy: true
        handler: (_, callback) ->
          options.log message: "Check if target (#{options.target}) exists", level: 'DEBUG', module: 'mecano/lib/cache'
          ssh2fs.exists options.ssh, options.target, (err, exists) =>
            return callback err if err
            if exists
              options.log message: "Target file exists", level: 'INFO', module: 'mecano/lib/cache'
              # If no checksum , we ignore MD5 check
              if options.force
                options.log message: "Force mode, cache will be overwritten", level: 'DEBUG', module: 'mecano/lib/cache'
                return callback null, true
              else if hash and typeof hash is 'string'
                # then we compute the checksum of the file
                options.log message: "Comparing #{algo} hash", level: 'DEBUG', module: 'mecano/lib/cache'
                file.hash options.ssh, options.target, algo, (err, c_hash) ->
                  return callback err if err
                  # And compare with the checksum provided by the user
                  if hash is c_hash
                    options.log message: "Hashes match, skipping", level: 'DEBUG', module: 'mecano/lib/cache'
                    return callback null, false
                  options.log message: "Hashes don't match, delete then re-download", level: 'WARN', module: 'mecano/lib/cache'
                  ssh2fs.unlink options.ssh, options.target, (err) ->
                    return callback err if err
                    callback null, true
              else
                options.log message: "Target file exists, check disabled, skipping", level: 'DEBUG', module: 'mecano/lib/cache'
                callback null, false
            else
              options.log message: "Target file does not exists", level: 'INFO', module: 'mecano/lib/cache'
              callback null, true
      , (err, status) ->
        @end() unless status
      # Place into cache
      if u.protocol in protocols_http
        fail = if options.fail then "--fail" else ''
        k = if u.protocol is 'https:' then '-k' else ''
        cmd = "curl #{fail} #{k} -s #{options.source} -o #{options.target}"
        cmd += " --location" if options.location
        cmd += " --header \"#{header}\"" for header in options.headers
        cmd += " -x #{options.proxy}" if options.proxy
        @mkdir
          ssh: if options.cache_local then null else options.ssh
          target: path.dirname options.target
        @execute
          cmd: cmd
          ssh: if options.cache_local then null else options.ssh
          unless_exists: options.target
      else
        @mkdir # todo: copy shall handle this
          target: "#{path.dirname options.target}"
        @copy
          source: "#{options.source}"
          target: "#{options.target}"
      @then (err, status) ->
        callback err, status, options.target

    module.exports.protocols_http = protocols_http = ['http:', 'https:']
    module.exports.protocols_ftp = protocols_ftp = ['ftp:', 'ftps:']

## Dependencies

    path = require 'path'
    url = require 'url'
    ssh2fs = require 'ssh2-fs'
    curl = require '../misc/curl'
    file = require '../misc/file'
