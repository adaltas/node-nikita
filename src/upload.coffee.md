
# `upload([goptions], options, callback)`

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
  console.log(err ? err.message : "File uploaded: " + !!uploaded);
});
```

    module.exports = (goptions, options, callback) ->
      wrap arguments, (options, next) ->
        options.log? "Mecano `upload`"
        return next Error "Required \"source\" option" unless options.source
        return next Error "Required \"destination\" option" unless options.destination
        options.log? "Mecano `upload`: source is \"#{options.source}\""
        options.log? "Mecano `upload`: destination is \"#{options.destination}\""
        # Start real work
        if options.binary
          uploaded = false
          options.log? "Mecano `upload`: enter binary mode"
          get_checksum = (ssh, path, algorithm, callback) ->
            if ssh
              execute
                ssh: ssh
                cmd: "openssl #{algorithm} #{path}"
                log: options.log
                stdout: options.stdout
                stderr: options.stderr
              , (err, executed, stdout, stderr) ->
                return callback err if err
                callback null, /[ ](.*)$/.exec(stdout.trim())[1]
            else
              misc.file.hash null, path, algorithm, callback
          do_src_checksum = ->
            return do_stat() unless options.md5 is true or options.sha1 is true
            algorithm = if options.md5 then 'md5' else 'sha1'
            options.log? "Mecano `upload`: get source #{algorithm} checksum"
            get_checksum null, options.source, algorithm, (err, checksum) ->
              return next err if err
              options[algorithm] = checksum
              options.log? "Mecano `upload`: #{algorithm} checksum is \"#{checksum}\""
              do_stat()
          do_stat = ->
            options.log? "Mecano `upload`: check if remote destination exists"
            fs.stat options.ssh, options.destination, (err, stat) ->
              return do_upload() if err?.code is 'ENOENT'
              return next err if err
              options.destination = "#{options.destination}/#{path.basename options.source}" if stat.isDirectory()
              do_dest_checksum()
          do_dest_checksum = ->
              return do_upload() unless options.md5 or options.sha1
              options.log? "Mecano `upload`: validate destination checksum, otherwise re-upload"
              switch
                when options.md5? then get_checksum options.ssh, options.destination, 'md5', (err, md5) ->
                  return next err if err
                  if md5 is options.md5
                  then next()
                  else do_upload()
                when options.sha1? then get_checksum options.ssh, options.destination, 'sha1', (err, sha1) ->
                  return next err if err
                  if sha1 is options.sha1
                  then next()
                  else do_upload()
          do_upload = ->
            options.log? "Mecano `upload`: write source"
            mkdir
              destination: "#{path.dirname options.destination}"
              ssh: options.ssh
              log: options.log
            , (err) ->
              fs.createWriteStream options.ssh, options.destination, (err, ws) ->
                return next err if err
                fs.createReadStream null, options.source, (err, rs) ->
                  return next err if err
                  rs.pipe(ws)
                  .on 'close', ->
                    uploaded = true
                    do_md5()
                  .on 'error', next
          do_md5 = ->
            return do_sha1() unless options.md5
            options.log? "Mecano `upload`: check destination md5"
            get_checksum options.ssh, options.destination, 'md5', (err, md5) ->
              return next new Error "Invalid md5 checksum" if md5 isnt options.md5
              do_sha1()
          do_sha1 = ->
            return do_end() unless options.sha1
            options.log? "Mecano `upload`: check destination sha1"
            get_checksum options.ssh, options.destination, 'sha1', (err, sha1) ->
              return next new Error "Invalid sha1 checksum" if sha1 isnt options.sha1
              do_end()
          do_end = ->
            options.log? "Mecano `upload`: upload succeed"
            next null, true
          return do_src_checksum()
        options = misc.merge options, local_source: true
        write options, (err, written) ->
          next err, written

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    execute = require './execute'
    write = require './write'
    mkdir = require './mkdir'
    misc = require './misc'
    wrap = require './misc/wrap'







