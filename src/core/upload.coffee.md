
# `upload(options, callback)`

Upload a file to a remote location. Options are identical to the "write"
function with the addition of the "binary" option.

## Options

*   `binary`   
    Fast upload implementation, discard all the other option and use its own
    stream based implementation.   
*   `from`   
    Replace from after this marker, a string or a regular expression.   
*   `to`   
    Replace to before this marker, a string or a regular expression.   
*   `match`   
    Replace this marker, a string or a regular expression.   
*   `replace`   
    The content to be inserted, used conjointly with the from, to or match
    options.   
*   `content`   
    Text to be written.   
*   `source`   
    File path from where to extract the content, do not use conjointly with
    content.   
*   `destination`   
    File path where to write content to.   
*   `backup`   
    Create a backup, append a provided string to the filename extension or a
    timestamp if value is not a string.   
*   `md5`   
    Validate uploaded file with md5 checksum (only for binary upload for now),
    may be the string checksum or will be deduced from source if "true".   
*   `sha1`   
    Validate uploaded file with sha1 checksum (only for binary upload for now),
    may be the string checksum or will be deduced from source if "true".   
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
*   `uploaded`   
    Number of uploaded files.   

## Example

```js
require('mecano').render({
  source: '/tmp/local_file',
  destination: '/tmp/remote_file'
  binary: true
}, function(err, uploaded){
  console.log(err ? err.message : 'File uploaded: ' + !!uploaded);
});
```

## Source Code

    module.exports = (options, callback) ->
      return callback Error "Required \"source\" option" unless options.source
      return callback Error "Required \"destination\" option" unless options.destination
      options.log message: "Source is \"#{options.source}\"", level: 'DEBUG', module: 'mecano/lib/upload'
      options.log message: "Destination is \"#{options.destination}\"", level: 'DEBUG', module: 'mecano/lib/upload'
      uploaded = false
      get_checksum = (ssh, path, algorithm, callback) =>
        if ssh
          @execute
            cmd: "openssl #{algorithm} #{path}"
          , (err, executed, stdout, stderr) ->
            return callback err if err
            callback null, /[ ](.*)$/.exec(stdout.trim())[1]
        else
          misc.file.hash null, path, algorithm, callback
      do_stat = ->
        options.log message: "Check if remote destination exists", level: 'DEBUG', module: 'mecano/lib/upload'
        fs.stat options.ssh, options.destination, (err, stat) ->
          return do_upload() if err?.code is 'ENOENT'
          return callback err if err
          options.log message: "Destination exists", level: 'INFO', module: 'mecano/lib/upload'
          if stat.isDirectory()
            options.log message: "Destination is a directory. Destination is now #{options.destination}/#{path.basename options.source}", level: 'INFO', module: 'mecano/lib/upload'
            options.destination = "#{options.destination}/#{path.basename options.source}" if stat.isDirectory()
          # Text file, delegate to `write`
          do_write()
      do_write = =>
        unless options.binary
          options = misc.merge options, local_source: true
          options.log message: "Not in binary mode. Calling mecano/lib/write", level: 'DEBUG', module: 'mecano/lib/upload'
          return @write options, (err, written) -> callback err, written
        else
          options.log message: "Enter binary mode", level: 'DEBUG', module: 'mecano/lib/upload'
          return do_src_checksum()
      do_src_checksum = ->
        return do_dest_checksum() unless options.md5 is true or options.sha1 is true
        algorithm = if options.md5 then 'md5' else 'sha1'
        options.log message: "Get source #{algorithm} checksum", level: 'DEBUG', module: 'mecano/lib/upload'
        get_checksum null, options.source, algorithm, (err, checksum) ->
          return callback err if err
          options[algorithm] = checksum
          options.log message: "#{algorithm} checksum is \"#{checksum}\"", level: 'INFO', module: 'mecano/lib/upload'
          do_dest_checksum()
      do_dest_checksum = ->
        return do_upload() unless options.md5 or options.sha1
        options.log message: "Validate destination checksum, otherwise re-upload", level: 'INFO', module: 'mecano/lib/upload'
        switch
          when options.md5? then get_checksum options.ssh, options.destination, 'md5', (err, md5) ->
            return callback err if err
            if md5 is options.md5
            then callback()
            else do_upload()
          when options.sha1? then get_checksum options.ssh, options.destination, 'sha1', (err, sha1) ->
            return callback err if err
            if sha1 is options.sha1
            then callback()
            else do_upload()
      do_upload = =>
        options.log message: "Write source", level: 'DEBUG', module: 'mecano/lib/upload'
        @mkdir
          destination: "#{path.dirname options.destination}"
        , (err) ->
          return next err if err
          fs.createWriteStream options.ssh, options.destination, (err, ws) ->
            return callback err if err
            fs.createReadStream null, options.source, (err, rs) ->
              return callback err if err
              rs.pipe ws
              .on 'close', ->
                uploaded = true
                do_md5()
              .on 'error', callback
      do_md5 = ->
        return do_sha1() unless options.md5
        options.log message: "Check destination md5", level: 'DEBUG', module: 'mecano/lib/upload'
        get_checksum options.ssh, options.destination, 'md5', (err, md5) ->
          return callback new Error "Invalid md5 checksum" if md5 isnt options.md5
          options.log message: "Destination md5 is valid", level: 'INFO', module: 'mecano/lib/upload'
          do_sha1()
      do_sha1 = ->
        return do_chown_chmod() unless options.sha1
        options.log message: "Check destination sha1", level: 'DEBUG', module: 'mecano/lib/upload'
        get_checksum options.ssh, options.destination, 'sha1', (err, sha1) ->
          return callback new Error "Invalid sha1 checksum" if sha1 isnt options.sha1
          options.log message: "Destination sha1 is valid", level: 'INFO', module: 'mecano/lib/upload'
          do_chown_chmod()
      do_chown_chmod = =>
        options.log message: "Check ownerships and permissions", level: 'DEBUG', module: 'mecano/lib/upload'
        @chown
          ssh: options.ssh
          destination: options.destination
          uid: options.uid
          gid: options.gid
          if: options.uid? or options.gid?
        @chmod
          ssh: options.ssh
          destination: options.destination
          mode: options.mode
          if: options.mode?
        @then (err, status) ->
          return callback err if err
          modified = true if status
          do_end()
      do_end = ->
        options.log message: "Upload succeed", level: 'INFO', module: 'mecano/lib/upload'
        callback null, true
      do_stat()

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    misc = require '../misc'
