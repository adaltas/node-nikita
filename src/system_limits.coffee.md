
# `system_limits(options, callback)` 

Control system limits for a user.

## Options

*   `destination` (string)   
    Where to write the file, default to "/etc/security/limits.d/#{options.user}.conf".   
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
*   `modified`   
    Indicates if the startup behavior has changed.   

## Example

```js
require('mecano').service_start([{
  ssh: ssh,
  name: 'gmetad'
}, function(err, modified){ /* do sth */ });
```

## Source Code


      # ctx.execute cmd: 'ulimit -Hn', (err, _, stdout) ->
      #   return next err if err
      #   max_nofile = stdout.trim()
      #   ctx.write [
      #     destination: '/etc/security/limits.d/hdfs.conf'
      #     write: [
      #       match: /^hdfs.+nofile.+$/mg
      #       replace: "hdfs    -    nofile   #{max_nofile}"
      #       append: true
      #     ,
      #       match: /^hdfs.+nproc.+$/mg
      #       replace: "hdfs    -    nproc    65536"
      #       append: true
      #     ]
      #     backup: true

    module.exports = (options, callback) ->
      return callback new Error "Missing required option 'user'" unless options.user
      options.nofile if options.nofile is true
      options.nproc = 65536 if options.nproc is true
      throw Error 'Invalid option "nofile"' if options.nofile? and typeof options.nofile not in ['number', 'boolean']
      throw Error 'Invalid option "nproc"' if options.nproc? and typeof options.nproc not in ['number', 'boolean']
      options.destination ?= "/etc/security/limits.d/#{options.user}.conf"
      write = []
      @
      # .execute
      #   cmd: "ulimit -Hn"
      #   shy: true
      #   if: options.nofile? and not options.nofile > 0
      # , (err, status, stdout) ->
      #   return callback err if err
      #   return unless status
      #   options.nofile = stdout.trim()
      # .call ->
      #   return unless options.nofile?
      #   write.push 
      #     match: /^#{options.user}.+nofile.+$/m
      #     replace: "#{options.user}    -    nofile   #{options.nofile}"
      #     append: true
      #   false
      .call ->
        return unless options.nproc?
        write.push 
          match: /^hdfs.+nproc.+$/m
          replace: "#{options.user}    -    nproc   #{options.nproc}"
          append: true
        false
      .write
        destination: options.destination
        write: write
        eof: true
        uid: options.uid
        gid: options.gid
        if: -> write.length
      .then callback

## Dependencies

    execute = require './execute'



