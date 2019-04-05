
# `nikita.file.download`

Download files using various protocols.

In local mode (with an SSH connection), the `http` protocol is handled with the
"request" module when executed locally, the `ftp` protocol is handled with the
"jsftp" and the `file` protocol is handle with the native `fs` module.

The behavior of download may be confusing wether you are running over SSH or
not. It's philosophy mostly rely on the target point of view. When download
run, the target is local, compared to the upload function where target
is remote.

A checksum may provided with the option "sha256", "sha1" or "md5" to validate the uploaded
file signature.

Caching is active if "cache_dir" or "cache_file" are defined to anything but false.
If cache_dir is not a string, default value is './'
If cache_file is not a string, default is source basename.

Nikita resolve the path from "cache_dir" to "cache_file", so if cache_file is an
absolute path, "cache_dir" will be ignored

If no cache is used, signature validation is only active if a checksum is
provided.

If cache is used, signature validation is always active, and md5sum is automatically
calculated if neither sha256, sh1 nor md5 is provided.

## Options

* `cache` (boolean, optional)   
  Activate the cache, default to true if either "cache_dir" or "cache_file" is
  activated.
* `cache_dir` (string, optional)   
  Path of the cache directory.
* `cache_file` (string|boolean, optional)   
  Cache the file on the executing machine, equivalent to cache unless an ssh
  connection is provided. If a string is provided, it will be the cache path.
  By default: basename of source
* `cookies` (array)   
  Extra cookies to include in the request when sending HTTP to a server.
* `force` (boolean)   
  Overwrite target file if it exists.
* `force_cache` (boolean)   
  Force cache overwrite if it exists
* `gid` (number|string, optional)   
  Group name or id who owns the target file.
* `http_headers` (array)   
  Extra  header  to include in the request when sending HTTP to a server.
* `location` (boolean)   
  If the server reports that the requested page has moved to a different
  location (indicated with a Location: header and a 3XX response code), this
  option will make curl redo the request on the new place.
* `md5` (MD5 Hash)   
  Hash of the file using MD5. Used to check integrity
* `mode` (octal mode)   
  Permissions of the target. If specified, nikita will chmod after download.
* `proxy` (string)   
  Use the specified HTTP proxy. If the port number is not specified, it is
  assumed at port 1080. See curl(1) man page.
* `sha1` (SHA-1 Hash)   
  Hash of the file using SHA-1. Used to check integrity.
* `sha256` (SHA-256 Hash)   
  Hash of the file using SHA-256. Used to check integrity.
* `source` (path)   
  File, HTTP URL, GIT repository. File is the default protocol if source
  is provided without any.
* `target` (path)   
  Path where to write the destination file.
* `uid` (number|string, optional)   
  User name or id who owns the target file.

## Callback parameters

* `err` (Error)   
  Error object if any.
* `output.status` (boolean)   
  Value is "true" if file was downloaded.

## File example

```js
require('nikita')
.download({
  source: 'file://path/to/something',
  target: 'node-sigar.tgz'
}, function(err, {status}){
  console.info(err ? err.message : 'File downloaded ' + status)
})
```

## HTTP example

```javascript
require('nikita')
.file.download({
  source: 'https://github.com/wdavidw/node-nikita/tarball/v0.0.1',
  target: 'node-sigar.tgz'
}, (err, {status}) => {
  console.info(err ? err.message : 'File downloaded ' + status)
})
```

## TODO

It would be nice to support alternatives sources such as FTP(S) or SFTP.

## Source Code

    module.exports = ({options}) ->
      @log message: 'Entering file.download', level: 'DEBUG', module: 'nikita/lib/file/download'
      # SSH connection
      ssh = @ssh options.ssh
      p = if ssh then path.posix else path
      # Options
      throw Error "Missing source: #{options.source}" unless options.source
      throw Error "Missing target: #{options.target}" unless options.target
      options.source = options.source.substr 7 if /^file:\/\//.test options.source
      stageDestination = null
      if options.md5?
        throw Error "Invalid MD5 Hash:#{options.md5}" unless typeof options.md5 in ['string', 'boolean']
        algo = 'md5'
        source_hash = options.md5
      else if options.sha1?
        throw Error "Invalid SHA-1 Hash:#{options.sha1}" unless typeof options.sha1 in ['string', 'boolean']
        algo = 'sha1'
        source_hash = options.sha1
      else if options.sha256?
        throw Error "Invalid SHA-256 Hash:#{options.sha256}" unless typeof options.sha256 in ['string', 'boolean']
        algo = 'sha256'
        source_hash = options.sha256
      else
        algo = 'md5'
      protocols_http = ['http:', 'https:']
      protocols_ftp = ['ftp:', 'ftps:']
      @log message: "Using force: #{JSON.stringify options.force}", level: 'DEBUG', module: 'nikita/lib/file/download' if options.force
      source_url = url.parse options.source
      # Disable caching if source is a local file and cache isnt exlicitly set by user
      options.cache = false if not options.cache? and source_url.protocol is null
      options.cache ?= !!(options.cache_dir or options.cache_file)
      options.http_headers ?= []
      options.cookies ?= []
      # Normalization
      options.target = if options.cwd then p.resolve options.cwd, options.target else p.normalize options.target
      throw Error "Non Absolute Path: target is #{JSON.stringify options.target}, SSH requires absolute paths, you must provide an absolute path in the target or the cwd option" if ssh and not p.isAbsolute options.target
      # Shortcircuit accelerator:
      # If we know the source signature and if the target file exists
      # we compare it with the target file signature and stop if they match
      @call
        if: typeof source_hash is 'string'
        shy: true
      , (_, callback) ->
        @log message: "Shortcircuit check if provided hash match target", level: 'WARN', module: 'nikita/lib/file/download'
        @file.hash options.target, algo: algo, (err, {hash}) ->
          err = null if err?.code is 'ENOENT'
          callback err, source_hash is hash
      , (err, {status}) ->
        return unless status
        @log message: "Destination with valid signature, download aborted", level: 'INFO', module: 'nikita/lib/file/download'
        @end()
      # Download the file and place it inside local cache
      # Overwrite the options.source and source_url properties to make them
      # look like a local file instead of an HTTP URL
      @file.cache
        if: options.cache
        # Local file must be readable by the current process
        ssh: false
        sudo: false
        source: options.source
        cache_dir: options.cache_dir
        cache_file: options.cache_file
        http_headers: options.http_headers
        cookies: options.cookies
        md5: options.md5
        proxy: options.proxy
        location: options.location
      , (err, {status, target}) ->
        throw err if err
        options.source = target if options.cache
        source_url = url.parse options.source
      # TODO
      # The current implementation seems inefficient. By modifying stageDestination,
      # we download the file, check the hash, and again treat it the HTTP URL 
      # as a local file and check hash again.
      @fs.stat target: options.target, relax: true, (err, {stats}) ->
        throw err if err and err.code isnt 'ENOENT'
        if not err and misc.stats.isDirectory stats.mode
          @log message: "Destination is a directory", level: 'DEBUG', module: 'nikita/lib/file/download'
          options.target = path.join options.target, path.basename options.source
        stageDestination = "#{options.target}.#{Date.now()}#{Math.round(Math.random()*1000)}"
      @call
        if: -> source_url.protocol in protocols_http
      , ->
        @log message: "HTTP Download", level: 'DEBUG', module: 'nikita/lib/file/download'
        @log message: "Download file from url using curl", level: 'INFO', module: 'nikita/lib/file/download'
        # Ensure target directory exists
        @system.mkdir
          shy: true
          target: path.dirname stageDestination
        # Download the file
        @system.execute
          cmd: [
            'curl'
            '--fail' if options.fail
            '--insecure' if source_url.protocol is 'https:'
            '--location' if options.location
            ...("--header '#{header.replace '\'', '\\\''}'" for header in options.http_headers)
            ...("--cookie '#{cookie.replace '\'', '\\\''}'" for cookie in options.cookies)
            "-s #{options.source}"
            "-o #{stageDestination}"
            "-x #{options.proxy}" if options.proxy
          ].join ' '
          shy: true
        hash_source = hash_target = null
        @file.hash stageDestination, algo: algo, (err, {hash}) ->
          throw err if err
          # Hash validation
          # Probably not the best to check hash, it only applies to HTTP for now
          if typeof source_hash is 'string' and source_hash isnt hash
            throw Error "Invalid downloaded checksum, found '#{hash}' instead of '#{source_hash}'" if source_hash isnt hash
          hash_source = hash
        @file.hash options.target, algo: algo, relax: true, (err, {hash}) ->
          throw err if err and err.code isnt 'ENOENT'
          hash_target = hash
        @call ({}, callback)->
          match = hash_source is hash_target
          @log if match
          then message: "Hash matches as '#{hash_source}'", level: 'INFO', module: 'nikita/lib/file/download' 
          else message: "Hash dont match, source is '#{hash_source}' and target is '#{hash_target}'", level: 'WARN', module: 'nikita/lib/file/download'
          callback null, not match
        @system.remove
          unless: -> @status -1
          shy: true
          target: stageDestination
      @call
        if: -> source_url.protocol not in protocols_http and not ssh
      , ->
        @log message: "File Download without ssh (with or without cache)", level: 'DEBUG', module: 'nikita/lib/file/download'
        hash_source = hash_target = null
        @file.hash target: options.source, algo: algo, (err, {hash}) ->
          throw err if err
          hash_source = hash
        @file.hash target: options.target, algo: algo, if_exists: true, (err, {hash}) ->
          throw err if err
          hash_target = hash
        @call ({}, callback)->
          match = hash_source is hash_target
          @log if match
          then message: "Hash matches as '#{hash_source}'", level: 'INFO', module: 'nikita/lib/file/download' 
          else message: "Hash dont match, source is '#{hash_source}' and target is '#{hash_target}'", level: 'WARN', module: 'nikita/lib/file/download'
          callback null, not match
        @system.mkdir
          if: -> @status -1
          shy: true
          target: path.dirname stageDestination
        @fs.copy
          if: -> @status -2
          source: options.source
          target: stageDestination
      @call
        if: -> source_url.protocol not in protocols_http and ssh
      , ->
        @log message: "File Download with ssh (with or without cache)", level: 'DEBUG', module: 'nikita/lib/file/download'
        hash_source = hash_target = null
        @file.hash target: options.source, algo: algo, ssh: false, sudo: false, (err, {hash}) ->
          throw err if err
          hash_source = hash
        @file.hash target: options.target, algo: algo, if_exists: true, (err, {hash}) ->
          throw err if err
          hash_target = hash
        @call ({}, callback)->
          match = hash_source is hash_target
          @log if match
          then message: "Hash matches as '#{hash_source}'", level: 'INFO', module: 'nikita/lib/file/download' 
          else message: "Hash dont match, source is '#{hash_source}' and target is '#{hash_target}'", level: 'WARN', module: 'nikita/lib/file/download'
          callback null, not match
        @system.mkdir
          if: -> @status -1
          shy: true
          target: path.dirname stageDestination
        @fs.createWriteStream
          if: -> @status -2
          target: stageDestination
          stream: (ws) ->
            rs = fs.createReadStream options.source
            rs.pipe ws
        , (err) ->
          @log if err
          then message: "Downloaded local source #{JSON.stringify options.source} to remote target #{JSON.stringify stageDestination} failed", level: 'ERROR', module: 'nikita/lib/file/download'
          else message: "Downloaded local source #{JSON.stringify options.source} to remote target #{JSON.stringify stageDestination}", level: 'INFO', module: 'nikita/lib/file/download'
      @call ->
        @log message: "Unstage downloaded file", level: 'DEBUG', module: 'nikita/lib/file/download'
        @system.move
          if: @status()
          source: stageDestination
          target: options.target
        @system.chmod
          if: options.mode?
          target: options.target
          mode: options.mode
        @system.chown
          if: options.uid? or options.gid?
          target: options.target
          uid: options.uid
          gid: options.gid

## Module Dependencies

    fs = require 'fs'
    path = require('path').posix # need to detect ssh connection
    url = require 'url'
    misc = require '../misc'
    curl = require '../misc/curl'
