
# `download(options, [goptions], callback)`

Download files using various protocols.

In local mode (with an SSH connection), the `http` protocol is handled with the
"request" module when executed locally, the `ftp` protocol is handled with the
"jsftp" and the `file` protocol is handle with the native `fs` module.

## Options

*   `source`   
    File, HTTP URL, FTP, GIT repository. File is the default protocol if source
    is provided without any.   
*   `destination`   
    Path where the file is downloaded.   
*   `force`   
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

## Callback parameters

*   `err`   
    Error object if any.   
*   `downloaded`   
    Number of download actions with modifications.   

## File example

```js
requir('mecano').download({
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
  user: "johndoe",
  pass: "12345"
, (err, downloaded) -> ...
```

    module.exports = (goptions, options, callback) ->
      wrap arguments, (options, next) ->
        # Validate parameters
        {destination, source, md5sum} = options
        # md5sum is used to validate the download
        return next new Error "Missing source: #{source}" unless source
        return next new Error "Missing destination: #{destination}" unless destination
        options.force ?= false
        stageDestination = "#{destination}.#{Date.now()}#{Math.round(Math.random()*1000)}"
        # Start real work
        prepare = () ->
          options.log? "Mecano `download`: Check if destination exists"
          # Note about next line: ssh might be null with file, not very clear
          fs.exists options.ssh, destination, (err, exists) ->
            # If we are forcing
            if options.force
              # Note, we should be able to move this before the "exists" check just above
              # because we don't seem to use. Maybe it still here because we were
              # expecting to remove the existing destination before downloading.
              download()
            # If the file exists and we have a checksum to compare and we are not forcing
            else if exists and md5sum
              # then we compute the checksum of the file
              misc.file.hash options.ssh, destination, 'md5', (err, hash) ->
                return next err if err
                # And compare with the checksum provided by the user
                return next() if hash is md5sum
                fs.unlink options.ssh, destination, (err) ->
                  return next err if err
                  download()
            # Get the checksum of the current file
            else if exists
              download()
            else download()
        download = () ->
          options.log? "Mecano `download`: Download the source"
          u = url.parse source
          if options.ssh
            if u.protocol is 'http:'
              cmd = "curl -s #{source} -o #{stageDestination}"
              cmd += " -x #{options.proxy}" if options.proxy
              execute
                ssh: options.ssh
                cmd: cmd
                log: options.log
                stdout: options.stdout
                stderr: options.stderr
              , (err, executed, stdout, stderr) ->
                return next curl.error err if err
                checksum()
            else if u.protocol is 'ftp:'
              return next new Error 'FTP download not supported over SSH'
            else
              fs.createReadStream options.ssh, u.pathname, (err, rs) ->
                return next err if err
                fs.createWriteStream null, stageDestination, (err, ws) ->
                  return next err if err
                  rs.pipe(ws)
                  .on 'close', ->
                    checksum()
                  .on 'error', next
          else
            fs.createWriteStream null, stageDestination, (err, ws) ->
              return next err if err
              if u.protocol is 'http:'
                options.url = source
                request(options).pipe(ws)
              else if u.protocol is 'ftp:'
                options.host ?= u.hostname
                options.port ?= u.port
                if u.auth
                  {user, pass} = u.auth.split ':'
                options.user ?= user
                options.pass ?= pass
                ftp = new Ftp options
                ftp.getGetSocket u.pathname, (err, rs) ->
                  return next err if err
                  rs.pipe ws
                  rs.resume()
              else
                fs.createReadStream null, u.pathname, (err, rs) ->
                  rs.pipe ws
              ws.on 'close', () ->
                checksum()
              ws.on 'error', (err) ->
                # No test against this but error in case
                # of connection issue leave an empty file
                remove
                  destination: stageDestination
                , next
        checksum = ->
          return unstage() unless md5sum
          options.log? "Mecano `download`: Compare the downloaded file with the user-provided checksum"
          misc.file.hash options.ssh, stageDestination, 'md5', (err, hash) ->
            return unstage() if hash is md5sum
            # Download is invalid, cleaning up
            misc.file.remove options.ssh, stageDestination, (err) ->
              return next err if err
              next new Error "Invalid checksum, found \"#{hash}\" instead of \"#{md5sum}\""
        unstage = ->
          # Note about next line: ssh might be null with file, not very clear
          # fs.rename options.ssh, stageDestination, destination, (err) ->
          #   return next err if err
          #   downloaded++
          #   next()
          options.log? "Mecano `download`: Move the downloaded file"
          move
            ssh: options.ssh
            source: stageDestination
            destination: destination
            source_md5: md5sum
            log: options.log
          , (err, moved) ->
            return next err if err
            next null, moved
        prepare()

## Dependencies

    fs = require 'ssh2-fs'
    url = require 'url'
    Ftp = require 'jsftp'
    request = require 'request'
    curl = require './misc/curl'
    misc = require './misc'
    wrap = require './misc/wrap'
    execute = require './execute'
    remove = require './remove'
    move = require './move'





