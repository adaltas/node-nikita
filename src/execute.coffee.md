
# `exec` `execute([goptions], options, callback)`

Run a command locally or with ssh if `host` or `ssh` is provided.

## Options

*   `cmd`           String, Object or array; Command to execute.
*   `code`          Expected code(s) returned by the command, int or array of int, default to 0.
*   `code_skipped`  Expected code(s) returned by the command if it has no effect, executed will not be incremented, int or array of int.
*   `trap_on_error` Exit immediately  if a commands exits with a non-zero status.   
*   `cwd`           Current working directory.
*   `env`           Environment variables, default to `process.env`.
*   `gid`           Unix group id.
*   `log`           Function called with a log related messages.
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.
*   `stdout`        Writable Stream in which commands output will be piped.
*   `stderr`        Writable Stream in which commands error will be piped.
*   `uid`           Unix user id.

## Callback parameters

*   `err`           Error if any enriched with the "code" property.
*   `executed`      Number of executed commandes.
*   `stdout`        Stdout value(s) unless `stdout` option is provided.
*   `stderr`        Stderr value(s) unless `stderr` option is provided.

## Create a user over SSH:

This example create a user on a remote server with the `useradd` command. It
print the error message if the command failed or an information message.

The "code_skipped" option indicates that the command is considered successfull
but without any impact if it exits with a status equal to "9".

```javascript
mecano.execute({
  ssh: ssh
  cmd: "useradd myfriend"
  code_skipped: 9
}, function(err, created, stdout, stderr){
  if(err){
    console.log(err.message);
  }else if(created){
    console.log('User created');
  }else{
    console.log('User already exists');
  }
})
```

## Implementation

    module.exports = (goptions, options, callback) ->
      callback = arguments[arguments.length-1]
      callback = null unless typeof callback is 'function'
      stds = if callback then callback.length > 2 else false
      wrap arguments, (options, next) ->
        options.log? "Mecano `execute`"
        # Validate parameters
        options = { cmd: options } if typeof options is 'string'
        return next new Error "Missing cmd: #{options.cmd}" unless options.cmd?
        options.code ?= [0]
        options.code = [options.code] unless Array.isArray options.code
        options.code_skipped ?= []
        options.code_skipped = [options.code_skipped] unless Array.isArray options.code_skipped
        if options.trap_on_error
          options.cmd = "set -e\n#{options.cmd}"
        # Start real work
        conditions.all options, next, ->
          options.log? "Mecano `execute`: #{options.cmd}"
          run = exec options
          stdout = stderr = []
          if options.stdout
            run.stdout.pipe options.stdout, end: false
          if stds
            run.stdout.on 'data', (data) ->
              stdout.push data
          if options.stderr
            run.stderr.pipe options.stderr, end: false
          if stds
            run.stderr.on 'data', (data) ->
              stderr.push data
          run.on "exit", (code) ->
            # Givent some time because the "exit" event is sometimes
            # called before the "stdout" "data" event when runing
            # `make test`
            setTimeout ->
              stdout = if stds then stdout.join('') else undefined
              stderr = if stds then stderr.join('') else undefined
              if options.stdout
                run.stdout.unpipe options.stdout
              if options.stderr
                run.stderr.unpipe options.stderr
              if options.code.indexOf(code) is -1 and options.code_skipped.indexOf(code) is -1
                options.log? "Mecano `execute`: invalid exit code \"#{code}\""
                err = new Error "Invalid Exit Code: #{code}"
                err.code = code
                return next err
              if options.code_skipped.indexOf(code) is -1
                executed = true
              else
                options.log? "Mecano `execute`: skip exit code \"#{code}\""
              next null, executed, stdout, stderr
            , 1

## Dependencies

    each = require 'each'
    exec = require 'ssh2-exec'
    misc = require './misc'
    wrap = require './misc/wrap'
    conditions = require './misc/conditions'
    child = require './misc/child'







