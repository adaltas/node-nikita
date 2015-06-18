
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

*   `source` (path)
    File, HTTP URL, FTP, GIT repository. File is the default protocol if source
    is provided without any.
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
*   `cache_dir` (path)
    If local_cache is not a string, the cache file path is resolved from cache dir and cache file.
    By default: './'
*   `cache_file` (string | boolean)
    Cache the file on the executing machine, equivalent to cache unless an ssh connection is
    provided. If a string is provided, it will be the cache path.
    By default: basename of source

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

    module.exports = (options, callback) ->
      {destination, source} = options
      return callback new Error "Missing source: #{source}" unless source
      return callback new Error "Missing destination: #{destination}" unless destination
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
      do_cache = => # Download the file and place it inside host cache
        return do_local_md5() unless options.cache_dir? or options.cache_file?
        return do_local_md5() if options.cache_dir is false or options.cache_file is false
        options.log? "Mecano `download`: using cache [DEBUG]"
        cache_path = if typeof options.cache_dir is 'string' then options.cache_dir else './'
        cache_file = if typeof options.cache_file is 'string' then options.cache_file
        else path.basename options.source
        cache_path = path.resolve cache_path, cache_file
        options.log? "Mecano `download`: cache path is '#{cache_path}' [INFO]"
        @download
          ssh: null
          source: options.source
          destination: cache_path
          cache_dir: false
          cache_file: false
          md5: options.md5
          sha1: options.sha1
          force: options.force_cache
        , (err, cached) =>
          return callback err if err
          options.log? if cached then "Mecano `download`: cache updated [WARN]"
          else "Mecano `download`: cache not modified [INFO]"
          options.log? "Mecano `download`: sending cache to destination [DEBUG]"
          push_file_opt =
            ssh: options.ssh
            source: cache_path
            destination: options.destination
            cache_dir: false
            cache_file: false
            mode: options.mode
            md5: options.md5
            sha1: options.sha1
            force: options.force
            uid: options.uid
            gid: options.gid
            log: options.log
            stdout: options.stdout
            stderr: options.stderr
          if hash then @download push_file_opt, callback
          else misc.file.hash null, cache_path, algo, (err, calc_hash) =>
            push_file_opt[algo] = calc_hash
            @download push_file_opt, callback
      do_local_md5 = ->
        return do_prepare() unless hash is true
        return callback Error "Unsupported hash 'true' in non-ssh mode" unless options.ssh
        {protocol} = url.parse options.source
        return callback Error "Unsupported hash 'true' with non-file protocols" if protocol in [protocols_http..., protocols_ftp...]
        misc.file.hash null, options.source, algo, (err, l_hash) ->
          return callback err if err
          hash = l_hash
          do_prepare()
      do_prepare = =>
        options.log? "Mecano `download`: Check if destination (#{destination}) exists [DEBUG]"
        # Note about next line: ssh might be null with file, not very clear
        fs.exists options.ssh, destination, (err, exists) =>
          return callback err if err
          if exists
            options.log? "Mecano `download`: destination exists [INFO]"
            # If no checksum , we ignore MD5 check
            if options.force
              options.log? "Mecano `download`: Force download [DEBUG]"
              return do_download()
            else if hash
              # then we compute the checksum of the file
              options.log? "Mecano `download`: comparing #{algo} hash [DEBUG]"
              misc.file.hash options.ssh, destination, algo, (err, c_hash) ->
                return callback err if err
                # And compare with the checksum provided by the user
                if hash is c_hash
                  options.log? "Mecano `download`: Hashes match, skipping [DEBUG]"
                  return callback()
                options.log? "Mecano `download`: Hashes don't match, delete then re-download [WARN]"
                fs.unlink options.ssh, destination, (err) ->
                  return callback err if err
                  do_download()
            else
              options.log? "Mecano `download`: destination exists, check disabled, skipping [DEBUG]"
              return callback null, false
          else
            options.log? "Mecano `download`: destination doesn't exists, cheking parent directories (#{path.join destination, '..'}) [DEBUG]"
            @mkdir
              destination: (path.join destination, '..')
            , (err, created) ->
              return callback err if err
              options.log? "Mecano `download`: Parent directory created [WARN]" if created
              do_download()
      do_download = =>
        options.log? "Mecano `download`: Download the source [DEBUG]"
        u = url.parse source
        if options.ssh
          if u.protocol in protocols_http
            k = if u.protocol is 'https:' then '-k' else ''
            cmd = "curl #{k} -s #{source} -o #{stageDestination}"
            cmd += " -x #{options.proxy}" if options.proxy
            @execute
              cmd: cmd
            , (err, executed) ->
              return callback curl.error err if err
              do_checksum()
          else if u.protocol in protocols_ftp
            return callback new Error 'FTP download not supported over SSH'
          else
            fs.createReadStream null, u.pathname, (err, rs) ->
              return callback err if err
              fs.createWriteStream options.ssh, stageDestination, (err, ws) ->
                return callback err if err
                rs.on 'error', callback
                rs.pipe(ws)
                .on 'close', ->
                  do_checksum()
                .on 'error', callback
        else
          fs.createWriteStream null, stageDestination, (err, ws) =>
            return callback err if err
            if u.protocol in protocols_http
              options.url = source
              request(options).pipe(ws)
            else if u.protocol in protocols_ftp
              options.host ?= u.hostname
              options.port ?= u.port
              if u.auth
                {user, pass} = u.auth.split ':'
              options.user ?= user
              options.pass ?= pass
              ftp = new Ftp options
              ftp.getGetSocket u.pathname, (err, rs) ->
                return callback err if err
                rs.pipe ws
                rs.resume()
            else
              fs.createReadStream null, u.pathname, (err, rs) ->
                rs.pipe ws
            ws.on 'close', () ->
              do_checksum()
            ws.on 'error', (err) =>
              # No test against this but error in case
              # of connection issue leave an empty file
              @remove
                ssh: null
                destination: stageDestination
              , callback
      do_checksum = ->
        return unstage() unless hash
        options.log? "Mecano `download`: Compare the downloaded file with the provided checksum [DEBUG]"
        misc.file.hash options.ssh, stageDestination, algo, (err, calc_hash) ->
          if hash is calc_hash
            "Mecano `download`: download is valid [INFO]"
            return unstage()
          # Download is invalid, cleaning up
          misc.file.remove options.ssh, stageDestination, (err) ->
            return callback err if err
            callback new Error "Invalid checksum, found \"#{calc_hash}\" instead of \"#{hash}\""
      unstage = =>
        # Note about next line: ssh might be null with file, not very clear
        # fs.rename options.ssh, stageDestination, destination, (err) ->
        #   return callback err if err
        #   downloaded++
        #   callback()
        options.log? "Mecano `download`: Move the downloaded file [DEBUG]"
        @move
          source: stageDestination
          destination: destination
          source_md5: options.md5
        , callback
      do_cache()

## Module Dependencies

    fs = require 'ssh2-fs'
    Ftp = require 'jsftp'
    path = require 'path'
    request = require 'request'
    url = require 'url'
    misc = require './misc'
    curl = require './misc/curl'
