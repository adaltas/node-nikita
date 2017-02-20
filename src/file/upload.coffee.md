
# `mecano.file.upload(options, [callback])`

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
*   `target`   
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
*   `status`   
    Value is "true" if file was uploaded.   

## Example

```js
require('mecano').upload({
  ssh: ssh
  source: '/tmp/local_file',
  target: '/tmp/remote_file'
}, function(err, status){
  console.log(err ? err.message : 'File uploaded: ' + status);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering upload", level: 'DEBUG', module: 'mecano/lib/file/upload'
      throw Error "Required \"source\" option" unless options.source
      throw Error "Required \"target\" option" unless options.target
      options.log message: "Source is \"#{options.source}\"", level: 'DEBUG', module: 'mecano/lib/file/upload'
      options.log message: "Destination is \"#{options.target}\"", level: 'DEBUG', module: 'mecano/lib/file/upload'
      status = false
      source_stat = null
      target_stat = null
      stage_target = "#{options.target}.#{Date.now()}#{Math.round(Math.random()*1000)}"
      if options.md5?
        return callback new Error "Invalid MD5 Hash:#{options.md5}" unless typeof options.md5 in ['string', 'boolean']
        algo = 'md5'
        # source_hash = options.md5
      else if options.sha1?
        return callback new Error "Invalid SHA-1 Hash:#{options.sha1}" unless typeof options.sha1 in ['string', 'boolean']
        algo = 'sha1'
        # source_hash = options.sha1
      else
        algo = 'md5'
      @call (_, callback) ->
        ssh2fs.stat options.ssh, options.source, (err, stat) ->
          callback err if err and err.code isnt 'ENOENT'
          source_stat = stat
          callback()
      @call (_, callback) ->
        ssh2fs.stat null, options.target, (err, stat) ->
          return callback() if err and err.code is 'ENOENT'
          return callback err if err
          target_stat = stat if stat.isFile()
          return callback() unless stat.isDirectory()
          options.target = path.resolve options.target, path.basename options.source
          ssh2fs.stat null, options.target, (err, stat) ->
            return callback() if err and err.code is 'ENOENT'
            return callback err if err
            target_stat = stat if stat.isFile()
            return callback() if stat.isFile()
            callback Error "Invalid target: #{options.target}"
      @call
        handler: (_, callback) ->
          return callback null, true unless target_stat
          file.compare_hash options.ssh, options.source, null, options.target, algo, (err, match) =>
            callback err, not match
      @mkdir
        if: -> @status -1
        ssh: null
        target: path.dirname stage_target
      @call
        if: -> @status -2
        handler: (_, callback) ->
          ssh2fs.createReadStream options.ssh, options.source, (err, rs) =>
            return callback err if err
            ws = fs.createWriteStream stage_target
            rs.pipe(ws)
            .on 'close', callback
            .on 'error', callback
      @call ->
        @move
          ssh: null
          if: @status()
          source: stage_target
          target: options.target
        , (err, status) ->
          options.log message: "Unstaged uploaded file", level: 'INFO', module: 'mecano/lib/file/upload' if status
        @chmod
          ssh: null
          target: options.target
          mode: options.mode
          if: options.mode?
        @system.chown
          ssh: null
          target: options.target
          uid: options.uid
          gid: options.gid
          if: options.uid? or options.gid?

## Dependencies

    fs = require 'fs'
    ssh2fs = require 'ssh2-fs'
    path = require 'path'
    misc = require '../misc'
    file = require '../misc/file'
