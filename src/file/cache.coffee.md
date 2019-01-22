
# `nikita.file.cache`

Download a file and place it on a local or remote folder for later usage.

## Options

* `cache_dir` (path)    
  If local_cache is not a string, the cache file path is resolved from cache dir and cache file.
  By default: './'    
* `cache_file` (string | boolean)   
  Alias for "target".   
* `cache_local` (boolean)   
  Apply to SSH mode, treat the cache file and directories as local from where
  the command is used instead of over SSH.   
* `fail` (boolean)   
  Send an error if the HTTP response code is invalid. Similar to the curl
  option of the same name.   
* `force` (boolean)   
  Overwrite the target file if it exists, bypass md5 verification.   
* `headers` (array)   
  Extra header  to include in the request when sending HTTP to a server.   
* `location` (boolean)   
  If the server reports that the requested page has moved to a different
  location (indicated with a Location: header and a 3XX response code), this
  option will make curl redo the request on the new place.   
* `proxy` (string)   
  Use the specified HTTP proxy. If the port number is not specified, it is
  assumed at port 1080. See curl(1) man page.   
* `source` (path)   
  File, HTTP URL, FTP, GIT repository. File is the default protocol if source
  is provided without any.   
* `target` (string | boolean)   
  Cache the file on the executing machine, equivalent to cache unless an ssh
  connection is provided. If a string is provided, it will be the cache path.
  Default to the basename of source.   

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

## Source Code

    module.exports = ({options}, callback) ->
      @log message: "Entering file.cache", level: 'DEBUG', module: 'nikita/lib/file/cache'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      options.source = options.argument if options.argument?
      throw Error "Missing source: '#{options.source}'" unless options.source
      throw Error "Missing one of 'target', 'cache_file' or 'cache_dir' option" unless options.cache_file or options.target or options.cache_dir
      options.target ?= options.cache_file
      options.target ?= path.basename options.source
      options.target = path.resolve options.cache_dir, options.target
      options.source = options.source.substr 7 if /^file:\/\//.test options.source
      options.headers ?= []
      # todo, also support options.algo and options.hash
      if options.md5?
        throw Error "Invalid MD5 Hash:#{options.md5}" unless typeof options.md5 in ['string', 'boolean']
        algo = 'md5'
        _hash = options.md5
      else if options.sha1?
        throw Error "Invalid SHA-1 Hash:#{options.sha1}" unless typeof options.sha1 in ['string', 'boolean']
        algo = 'sha1'
        _hash = options.sha1
      else if options.sha256?
        throw Error "Invalid SHA-1 Hash:#{options.sha256}" unless typeof options.sha256 in ['string', 'boolean']
        algo = 'sha256'
        _hash = options.sha256
      else
        algo = 'md5'
        _hash = false
      u = url.parse options.source
      @call (_, callback) ->
        unless u.protocol is null
          @log message: "Bypass source hash computation for non-file protocols", level: 'WARN', module: 'nikita/lib/file/cache'
          return callback()
        return callback() if _hash isnt true
        @file.hash options.source, (err, {hash}) ->
          return callback err if err
          @log message: "Computed hash value is '#{hash}'", level: 'INFO', module: 'nikita/lib/file/cache'
          _hash = hash
          callback()
      # Download the file if
      # - file doesnt exist
      # - option force is provided
      # - hash isnt true and doesnt match
      @call shy: true, ({}, callback) ->
        @log message: "Check if target (#{options.target}) exists", level: 'DEBUG', module: 'nikita/lib/file/cache'
        @fs.exists ssh: options.ssh, target: options.target, (err, {exists}) =>
          return callback err if err
          if exists
            @log message: "Target file exists", level: 'INFO', module: 'nikita/lib/file/cache'
            # If no checksum , we ignore MD5 check
            if options.force
              @log message: "Force mode, cache will be overwritten", level: 'DEBUG', module: 'nikita/lib/file/cache'
              return callback null, true
            else if _hash and typeof _hash is 'string'
              # then we compute the checksum of the file
              @log message: "Comparing #{algo} hash", level: 'DEBUG', module: 'nikita/lib/file/cache'
              @file.hash options.target, (err, {hash}) =>
                return callback err if err
                # And compare with the checksum provided by the user
                if _hash is hash
                  @log message: "Hashes match, skipping", level: 'DEBUG', module: 'nikita/lib/file/cache'
                  return callback null, false
                @log message: "Hashes don't match, delete then re-download", level: 'WARN', module: 'nikita/lib/file/cache'
                @fs.unlink ssh: options.ssh, target: options.target, (err) ->
                  return callback err if err
                  callback null, true
            else
              @log message: "Target file exists, check disabled, skipping", level: 'DEBUG', module: 'nikita/lib/file/cache'
              callback null, false
          else
            @log message: "Target file does not exists", level: 'INFO', module: 'nikita/lib/file/cache'
            callback null, true
      , (err, {status}) ->
        @end() unless status
      # Place into cache
      if u.protocol in protocols_http
        fail = if options.fail then "--fail" else ''
        k = if u.protocol is 'https:' then '-k' else ''
        cmd = "curl #{fail} #{k} -s #{options.source} -o #{options.target}"
        cmd += " --location" if options.location
        cmd += " --header \"#{header}\"" for header in options.headers
        cmd += " -x #{options.proxy}" if options.proxy
        @system.mkdir
          ssh: if options.cache_local then false else options.ssh
          target: path.dirname options.target
        @system.execute
          cmd: cmd
          ssh: if options.cache_local then false else options.ssh
          unless_exists: options.target
      else
        @system.mkdir # todo: copy shall handle this
          target: "#{path.dirname options.target}"
        @system.copy
          source: "#{options.source}"
          target: "#{options.target}"
      # TODO: validate the cache
      @next (err, {status}) ->
        callback err, status: status, target: options.target

    module.exports.protocols_http = protocols_http = ['http:', 'https:']
    module.exports.protocols_ftp = protocols_ftp = ['ftp:', 'ftps:']

## Dependencies

    path = require 'path'
    url = require 'url'
    curl = require '../misc/curl'
