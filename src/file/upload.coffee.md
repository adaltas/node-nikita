
# `nikita.file.upload`

Upload a file to a remote location. Options are identical to the "write"
function with the addition of the "binary" option.

## Options

* `binary`   
  Fast upload implementation, discard all the other option and use its own
  stream based implementation.
* `from`   
  Replace from after this marker, a string or a regular expression.
* `to`   
  Replace to before this marker, a string or a regular expression.
* `match`   
  Replace this marker, a string or a regular expression.
* `replace`   
  The content to be inserted, used conjointly with the from, to or match
  options.
* `content`   
  Text to be written.
* `source`   
  File path from where to extract the content, do not use conjointly with
  content.
* `target`   
  File path where to write content to.
* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `md5`   
  Validate uploaded file with md5 checksum (only for binary upload for now),
  may be the string checksum or will be deduced from source if "true".
* `sha1`   
  Validate uploaded file with sha1 checksum (only for binary upload for now),
  may be the string checksum or will be deduced from source if "true".
* `ssh` (object|ssh2)   
  Run the action on a remote server using SSH, an ssh2 instance or an
  configuration object used to initialize the SSH connection.
* `stdout` (stream.Writable)   
  Writable EventEmitter in which the standard output of executed commands will
  be piped.
* `stderr` (stream.Writable)   
  Writable EventEmitter in which the standard error output of executed command
  will be piped.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file was uploaded.   

## Example

```js
require('nikita')
.file.upload({
  ssh: ssh
  source: '/tmp/local_file',
  target: '/tmp/remote_file'
}, function(err, {status}){
  console.info(err ? err.message : 'File uploaded: ' + status);
});
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering file.upload", level: 'DEBUG', module: 'nikita/lib/file/upload'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
      throw Error "Required \"source\" option" unless options.source
      throw Error "Required \"target\" option" unless options.target
      @log message: "Source is \"#{options.source}\"", level: 'DEBUG', module: 'nikita/lib/file/upload'
      @log message: "Destination is \"#{options.target}\"", level: 'DEBUG', module: 'nikita/lib/file/upload'
      status = false
      # source_stats = null
      target_stats = null
      stage_target = null
      if options.md5?
        return callback Error "Invalid MD5 Hash:#{options.md5}" unless typeof options.md5 in ['string', 'boolean']
        algo = 'md5'
      else if options.sha1?
        return callback Error "Invalid SHA-1 Hash:#{options.sha1}" unless typeof options.sha1 in ['string', 'boolean']
        algo = 'sha1'
      else
        algo = 'md5'
      # Stat the target and redefine its path if a directory
      @call (_, callback) ->
        @fs.stat ssh: false, target: options.target, (err, {stats}) ->
          # Unexpected err
          return callback err if err and err.code isnt 'ENOENT'
          # Target does not exists
          return callback() if err
          # Target is a file
          if misc.stats.isFile stats.mode
            target_stats = stats
            return callback()
          # Target is invalid
          else unless misc.stats.isDirectory stats.mode
            throw Error "Invalid Target: expect a file, a symlink or a directory for #{JSON.stringify options.target}"
          # Target is a directory
          options.target = path.resolve options.target, path.basename options.source
          @fs.stat ssh: false, target: options.target, (err, {stats}) ->
            return callback() if err and err.code is 'ENOENT'
            return callback err if err
            target_stats = stats if misc.stats.isFile stats.mode
            return callback() if misc.stats.isFile stats.mode
            callback Error "Invalid target: #{options.target}"
      @call ->
        # Now that we know the real name of the target, define a temporary file to write
        stage_target = "#{options.target}.#{Date.now()}#{Math.round(Math.random()*1000)}"
      @call ({}, callback) ->
        return callback null, true unless target_stats
        hash_source = hash_target = null
        @file.hash target: options.source, algo: algo, (err, {hash}) ->
          return callback err if err
          hash_source = hash
        @file.hash target: options.target, algo: algo, ssh: false, (err, {hash}) ->
          return callback err if err
          hash_target = hash
        @call ->
          match = hash_source is hash_target
          @log if match
          then message: "Hash matches as '#{hash_source}'", level: 'INFO', module: 'nikita/lib/file/download' 
          else message: "Hash dont match, source is '#{hash_source}' and target is '#{hash_target}'", level: 'WARN', module: 'nikita/lib/file/download'
          callback null, not match
      @call
        if: -> @status -1
      , ->
        @system.mkdir
          ssh: false
          target: path.dirname stage_target
        @fs.createReadStream
          target: options.source
          stream: (rs) ->
            ws = fs.createWriteStream stage_target
            rs.pipe ws
        @system.move
          ssh: false
          source: stage_target
          target: options.target
        , (err, {status}) ->
          @log message: "Unstaged uploaded file", level: 'INFO', module: 'nikita/lib/file/upload' if status
      @system.chmod
        ssh: false
        target: options.target
        mode: options.mode
        if: options.mode?
      @system.chown
        ssh: false
        target: options.target
        uid: options.uid
        gid: options.gid
        if: options.uid? or options.gid?

## Dependencies

    fs = require 'fs'
    path = require 'path'
    misc = require '../misc'
    file = require '../misc/file'
