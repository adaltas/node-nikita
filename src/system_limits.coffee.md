
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

Count the number of sub-process for a process:

```bash
ls /proc/14986/task | wc
ps -L p $pid --no-headers | wc -l
```

Count the number of sub-process for a user:

```bash
ps -L -u $user --no-headers | wc -l
```

## Source Code

    module.exports = (options, callback) ->
      return callback new Error "Missing required option 'user'" unless options.user
      options.nofile if options.nofile is true
      options.nproc = 65536 if options.nproc is true
      throw Error 'Invalid option "nofile"' if options.nofile? and typeof options.nofile not in ['number', 'boolean']
      throw Error 'Invalid option "nproc"' if options.nproc? and typeof options.nproc not in ['number', 'boolean']
      options.destination ?= "/etc/security/limits.d/#{options.user}.conf"
      write = []
      @
      .execute
        cmd: "ulimit -Hn"
        shy: true
        if: options.nofile is true
      , (err, status, stdout) ->
        # console.log err, status, stdout
        return callback err if err
        return unless status
        options.nofile = stdout.trim()
      .call ->
        return unless options.nofile?
        write.push 
          match: ///^#{options.user}.+nofile.+$///m
          replace: "#{options.user}    -    nofile   #{options.nofile}"
          append: true
        false
      .call ->
        return unless options.nproc?
        write.push
          match: ///^#{options.user}.+nproc.+$///m
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



