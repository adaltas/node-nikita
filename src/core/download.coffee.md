
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

*   `cache_dir` (path)   
    If local_cache is not a string, the cache file path is resolved from cache dir and cache file.
    By default: './'   
*   `cache_file` (string | boolean)   
    Cache the file on the executing machine, equivalent to cache unless an ssh connection is
    provided. If a string is provided, it will be the cache path.   
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
      {destination, source} = options
      return callback new Error "Missing source: #{source}" unless source
      return callback new Error "Missing destination: #{destination}" unless destination
      options.source = source = options.source.substr 7 if /^file:\/\//.test options.source
      stageDestination = "#{destination}.#{Date.now()}#{Math.round(Math.random()*1000)}"
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
      protocols_http = ['http:', 'https:']
      protocols_ftp = ['ftp:', 'ftps:']
      use_cache = !! (options.cache_dir or options.cache_file)
      hash_info = null
      # Download the file if
      # - file doesnt exist
      # - option force is provided
      # - hash isnt true and doesnt match
      @call
        handler: (_, callback) ->
          u = url.parse source
          unless u.protocol is null
            options.log message: "Bypass source hash computation for non-file protocols", level: 'INFO', module: 'mecano/src/download'
            return callback()
          return callback() if hash isnt true
          misc.file.hash options.ssh, source, algo, (err, value) ->
            return callback err if err
            options.log message: "Computed hash value is '#{value}'", level: 'INFO', module: 'mecano/src/download'
            hash = value
            callback()
      @call
        shy: true
        handler: (_, callback) ->
          options.log message: "Check if destination (#{destination}) exists", level: 'DEBUG', module: 'mecano/src/download'
          # Note about next line: ssh might be null with file, not very clear
          ssh2fs.exists options.ssh, destination, (err, exists) =>
            return callback err if err
            if exists
              options.log message: "Destination exists", level: 'INFO', module: 'mecano/src/download'
              # If no checksum , we ignore MD5 check
              if options.force
                options.log message: "Force download", level: 'INFO', module: 'mecano/src/download'
                return callback null, true
              else if hash and typeof hash is 'string'
                # then we compute the checksum of the file
                options.log message: "Comparing #{algo} hash", level: 'DEBUG', module: 'mecano/src/download'
                misc.file.hash options.ssh, destination, algo, (err, c_hash) ->
                  return callback err if err
                  # And compare with the checksum provided by the user
                  if hash is c_hash
                    options.log message: "Hashes match, skipping", level: 'DEBUG', module: 'mecano/src/download'
                    return callback null, false
                  options.log message: "Hashes don't match, delete then re-download", level: 'WARN', module: 'mecano/src/download'
                  ssh2fs.unlink options.ssh, destination, (err) ->
                    return callback err if err
                    callback null, true
              else
                options.log message: "Destination exists, check disabled, skipping", level: 'DEBUG', module: 'mecano/src/download'
                callback null, false
            else
              callback null, true
      , (err, status) ->
        @end() unless status
      @cache # Download the file and place it inside local cache
        if: use_cache
        ssh: null
        source: options.source
        cache_dir: options.cache_dir
        cache_file: options.cache_file
        headers: options.headers
        md5: options.md5
        proxy: options.proxy
      , (err, cached, file) ->
        throw err if err
        source = file if use_cache
      @call (_, callback) -> # File Download
        u = url.parse source
        return callback() unless u.protocol is null
        if not use_cache
          hash_info = ssh: options.ssh, source: options.source if hash is true
          @mkdir path.dirname stageDestination
          @copy
            source: options.source
            destination: stageDestination
          @then callback
        else if not options.ssh and use_cache
          hash_info = ssh: null, source: source if hash is true
          rs = fs.createReadStream source
          ws = fs.createWriteStream stageDestination
          rs.pipe(ws)
          .on 'close', callback
          .on 'error', callback
        else if options.ssh and use_cache
          hash_info = ssh: null, source: source if hash is true
          rs = fs.createReadStream source
          ssh2fs.writeFile options.ssh, stageDestination, rs, (err) ->
            callback err
        else
          callback Error "Unsupported API"
      @call (_, callback) -> # HTTP Download
        u = url.parse source
        return callback() unless u.protocol in protocols_http
        # is_http = u.protocol in protocols_http
        if not use_cache
          hash_info = ssh: options.ssh, source: options.source if hash is true
          fail = if options.fail then "--fail" else ''
          k = if u.protocol is 'https:' then '-k' else ''
          cmd = "curl #{fail} #{k} -s #{options.source} -o #{stageDestination}"
          cmd += " -x #{options.proxy}" if options.proxy
          options.log message: "Download file from url using curl", level: 'INFO', module: 'mecano/src/download'
          @mkdir path.dirname stageDestination
          @execute
            cmd: cmd
            # not_if_exists: options.cache_file
          @then callback
        else if not options.ssh and use_cache
          hash_info = ssh: null, source: source if hash is true
          rs = fs.createReadStream source
          ws = fs.createWriteStream stageDestination
          rs.pipe(ws)
          .on 'close', callback
          .on 'error', callback
        else if options.ssh and use_cache
          hash_info = ssh: null, source: source if hash is true
          rs = fs.createReadStream source
          ssh2fs.writeFile options.ssh, stageDestination, rs, (err) ->
            callback err
        else
          callback Error "Unsupported API"
      @call (_, callback) -> # Convert boolean hash
        return callback() unless hash_info
        misc.file.hash hash_info.ssh, hash_info.source, algo, (err, calc_hash) ->
          hash = calc_hash
          callback err
      @call (_, callback) -> # Hash Validation
        return callback() unless hash
        options.log message: "Compare the downloaded file with the provided checksum", level: 'DEBUG', module: 'mecano/src/download'
        misc.file.hash options.ssh, stageDestination, algo, (err, calc_hash) ->
          return callback err if err
          if hash is calc_hash
            options.log message: "Mecano `download`: Hash match with staged uploaded file", level: 'DEBUG', module: 'mecano/src/download'
            return callback()
          # Download is invalid, cleaning up
          misc.file.remove options.ssh, stageDestination, (err) ->
            return callback err if err
            callback Error "Invalid checksum, found \"#{calc_hash}\" instead of \"#{hash}\""
      @call ->
        # Note about next line: ssh might be null with file, not very clear
        # fs.rename options.ssh, stageDestination, destination, (err) ->
        #   return callback err if err
        #   downloaded++
        #   callback()
        options.log message: "Unstage downloaded file", level: 'DEBUG', module: 'mecano/src/download'
        @move
          source: stageDestination
          destination: destination
          source_md5: options.md5
        @chmod
          destination: destination
          mode: options.mode
          if: options.mode?
        @chown
          destination: destination
          uid: options.uid
          gid: options.gid
          if: options.uid? or options.gid?

## Module Dependencies

    fs = require 'fs'
    ssh2fs = require 'ssh2-fs'
    # Ftp = require 'jsftp'
    path = require 'path'
    url = require 'url'
    misc = require '../misc'
    curl = require '../misc/curl'
