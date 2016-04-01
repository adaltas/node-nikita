
# `download(options, callback)`

Download files using various protocols.

In local mode (with an SSH connection), the `http` protocol is handled with the
"request" module when executed locally, the `ftp` protocol is handled with the
"jsftp" and the `file` protocol is handle with the native `fs` module.

The behavior of download may be confusing wether you are running over SSH or
not. It's philosophy mostly rely on the destination point of view. When download
run, the destination is local, compared to the upload function where destination
is remote.

A checksum may provided with the option "sha1" or "md5" to validate the uploaded
file signature.

Caching is active if "cache_dir" or "cache_file" are defined to anything but false.
If cache_dir is not a string, default value is './'
If cache_file is not a string, default is source basename.

Mecano resolve the path from "cache_dir" to "cache_file", so if cache_file is an
absolute path, "cache_dir" will be ignored

If no cache is used, signature validation is only active if a checksum is
provided.

If cache is used, signature validation is always active, and md5sum is automatically
calculated if neither md5 nor sha1 is provided

## Options

*   `cache` (boolean)
    Activate the cache, default to true if either "cache_dir" or "cache_file" is
    activated.   
*   `cache_dir` (path)   
    If local_cache is not a string, the cache file path is resolved from cache
    dir and cache file.
    By default: './'   
*   `cache_file` (string | boolean)   
    Cache the file on the executing machine, equivalent to cache unless an ssh
    connection is provided. If a string is provided, it will be the cache path.   
    By default: basename of source   
*   `destination` (path)   
    Path where the file is downloaded.   
*   `force` (boolean)   
    Overwrite destination file if it exists.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   
*   `sha1` (SHA-1 Hash)   
    Hash of the file using SHA-1. Used to check integrity   
*   `md5` (MD5 Hash)   
    Hash of the file using MD5. Used to check integrity
*   `force_cache` (boolean)   
    Force cache overwrite if it exists   
*   `headers` (array)   
    Extra  header  to include in the request when sending HTTP to a server.   
*   `uid` (string | int)   
    UID of the destination. If specified, mecano will chown after download   
*   `mode` (octal mode)   
    Permissions of the destination. If specified, mecano will chmod after download   
*   `proxy` (string)   
    Use the specified HTTP proxy. If the port number is not specified, it is
    assumed at port 1080. See curl(1) man page.   
*   `source` (path)   
    File, HTTP URL, FTP, GIT repository. File is the default protocol if source
    is provided without any.   

## Callback parameters

*   `err`
    Error object if any.
*   `downloaded`
    Number of download actions with modifications.

## File example

```js
require('mecano').download({
  source: 'file://path/to/something',
  destination: 'node-sigar.tgz'
}, function(err, downloaded){
  console.log(err ? err.message : 'File was downloaded: ' + downloaded);
});
```

## HTTP example

```coffee
mecano.download
  source: 'https://github.com/wdavidw/node-mecano/tarball/v0.0.1'
  destination: 'node-sigar.tgz'
, (err, downloaded) -> ...
```

## FTP example

```coffee
mecano.download
  source: 'ftp://myhost.com:3334/wdavidw/node-mecano/tarball/v0.0.1'
  destination: 'node-sigar.tgz'
  user: 'johndoe',
  pass: '12345'
, (err, downloaded) -> ...
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering download", level: 'DEBUG', module: 'mecano/lib/download'
      {destination, source} = options
      return callback new Error "Missing source: #{source}" unless source
      return callback new Error "Missing destination: #{destination}" unless destination
      options.source = options.source.substr 7 if /^file:\/\//.test options.source
      stageDestination = "#{destination}.#{Date.now()}#{Math.round(Math.random()*1000)}"
      if options.md5?
        return callback new Error "Invalid MD5 Hash:#{options.md5}" unless typeof options.md5 in ['string', 'boolean']
        algo = 'md5'
        source_hash = options.md5
      else if options.sha1?
        return callback new Error "Invalid SHA-1 Hash:#{options.sha1}" unless typeof options.sha1 in ['string', 'boolean']
        algo = 'sha1'
        source_hash = options.sha1
      else
        algo = 'md5'
        # source_hash = false
      protocols_http = ['http:', 'https:']
      protocols_ftp = ['ftp:', 'ftps:']
      options.cache ?= !!(options.cache_dir or options.cache_file)
      # hash_info = null
      options.log message: "Using force: #{JSON.stringify options.force}", level: 'DEBUG', module: 'mecano/lib/download'
      source_url = url.parse source
      @call # Accelarator in case we know the destination signature
        if: typeof source_hash is 'string'
        shy: true
        handler: (_, callback) ->
          options.log message: "Shortcircuit check if provided hash match destination", level: 'WARN', module: 'mecano/lib/download'
          misc.file.hash options.ssh, options.destination, algo, (err, hash) =>
            err = null if err?.code is 'ENOENT'
            callback err, source_hash is hash
        , (err, end) ->
          return unless end
          options.log message: "Destination with valid signature, download aborted", level: 'INFO', module: 'mecano/lib/download'
          @end()
      @cache # Download the file and place it inside local cache
        if: options.cache
        ssh: null
        source: options.source
        cache_dir: options.cache_dir
        cache_file: options.cache_file
        headers: options.headers
        md5: options.md5
        proxy: options.proxy
      , (err, cached, file) ->
        throw err if err
        options.source = file if options.cache
        source_url = url.parse options.source
      @call # HTTP Download
        if: -> source_url.protocol in protocols_http
        handler: (_, callback) ->
          fail = if options.fail then "--fail" else ''
          k = if source_url.protocol is 'https:' then '-k' else ''
          cmd = "curl #{fail} #{k} -s #{options.source} -o #{stageDestination}"
          cmd += " -x #{options.proxy}" if options.proxy
          options.log message: "Download file from url using curl", level: 'INFO', module: 'mecano/lib/download'
          @mkdir
            shy: true
            destination: path.dirname stageDestination
          @execute
            cmd: cmd
            shy: true
          @call
            if: typeof source_hash is 'string'
            handler: (_, callback) ->
              misc.file.hash options.ssh, stageDestination, algo, (err, hash) =>
                return callback Error "Invalid downloaded checksum, found '#{hash}' instead of '#{source_hash}'" if source_hash isnt hash
                callback()
          @call (_, callback) ->
            compare_hash null, stageDestination, options.ssh, options.destination, algo, (err, match, hash1, hash2) ->
              options.log message: "Downloaded hash is '#{hash1}'", level: 'INFO', module: 'mecano/lib/download'
              options.log message: "Destination hash is '#{hash2}'", level: 'INFO', module: 'mecano/lib/download'
              callback err, not match
          @remove
            unless: -> @status -1
            shy: true
            destination: stageDestination
          @then callback
      @call # File Download without cache
        if: -> source_url.protocol is null and not options.cache
        handler: (_, callback) ->
          options.log  message: "No cache, rely on copy", level: 'DEBUG', module: 'mecano/lib/download'
          @call (_, callback) ->
            compare_hash options.ssh, options.source, options.ssh, options.destination, algo, (err, match, hash1, hash2) ->
              options.log message: "Hash dont match, source is '#{hash1}' and destination is '#{hash2}'", level: 'WARN', module: 'mecano/lib/download' unless match
              options.log message: "Hash matches as '#{hash1}'", level: 'INFO', module: 'mecano/lib/download' if match
              callback err, not match
          @mkdir
            if: -> @status -1
            shy: true
            destination: path.dirname stageDestination
          @call
            if: -> @status -2
            handler: (_, callback) ->
              rs = fs.createReadStream options.source
              rs.on 'error', (err) ->
                options.log  message: "No such source file: #{options.source} (ssh is #{JSON.stringify !!options.ssh})", level: 'ERROR', module: 'mecano/lib/download'
                err.message = 'No such source file'
                callback err
              ws = fs.createWriteStream stageDestination
              rs.pipe(ws)
              .on 'close', callback
              .on 'error', callback
          @then callback
      @call # File Download with cache and no ssh
        if: -> source_url.protocol is null and options.cache and not options.ssh
        handler: (_, callback) ->
          options.log  message: "With cache and without SSH, ", level: 'DEBUG', module: 'mecano/lib/download'
          @call (_, callback) ->
            compare_hash null, options.source, options.ssh, options.destination, algo, (err, match) ->
              callback err, not match
          @mkdir
            if: -> @status -1
            shy: true
            destination: path.dirname stageDestination
          @call
            if: -> @status -2
            handler: (_, callback) ->
              rs = fs.createReadStream options.source
              rs.on 'error', (err) ->
                console.log 'rs on error', err
              ws = fs.createWriteStream stageDestination
              rs.pipe(ws)
              .on 'close', callback
              .on 'error', callback
          @then callback
      @call # File Download with cache and ssh
        if: -> source_url.protocol is null and options.cache and options.ssh
        handler: (_, callback) ->
          @call (_, callback) ->
            compare_hash null, options.source, options.ssh, options.destination, algo, (err, match, hash1, hash2) ->
              callback err, not match
          @mkdir
            if: -> @status -1
            shy: true
            destination: path.dirname stageDestination
          @call
            if: -> @status -2
            handler: (_, callback) ->
              rs = fs.createReadStream options.source
              rs.on 'error', (err) ->
                console.log 'rs on error', err
              ssh2fs.writeFile options.ssh, stageDestination, rs, (err) ->
                options.log "Upload failed from local to remote" if err
                callback err
          @then callback
      @call ->
        options.log message: "Unstage downloaded file", level: 'DEBUG', module: 'mecano/lib/download'
        @move
          if: @status()
          source: stageDestination
          destination: options.destination
        @chmod
          destination: options.destination
          mode: options.mode
          if: options.mode?
        @chown
          destination: options.destination
          uid: options.uid
          gid: options.gid
          if: options.uid? or options.gid?

    compare_hash = (ssh1, file1, ssh2, file2, algo, callback) ->
      misc.file.hash ssh1, file1, algo, (err, hash1) ->
        return callback err if err
        misc.file.hash ssh2, file2, algo, (err, hash2) ->
          err = null if err?.code is 'ENOENT'
          return callback err if err
          callback null, hash1 is hash2, hash1, hash2

## Module Dependencies

    fs = require 'fs'
    ssh2fs = require 'ssh2-fs'
    # Ftp = require 'jsftp'
    path = require 'path'
    url = require 'url'
    misc = require '../misc'
    curl = require '../misc/curl'
