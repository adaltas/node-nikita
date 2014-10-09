
# `execute(options, [goptions], callback)`

Run a command locally or with ssh if `host` or `ssh` is provided.   

## Exit codes

The properties "code" and "code_skipped" are important to determine whether an
action failed or succeed with or without modifications. An action is expected to
execute successfully with modifications if the exit code match one of the value
in "code", by default "0". Otherwise, it is considered to have failed and an
error is passed to the user callback. The "code_skipped" option is used to
define one or more exit codes that are considered successfull but without
creating any modifications.

## Options

*   `cmd`   
    String, Object or array; Command to execute.   
*   `code`   (string|array)
    Expected code(s) returned by the command, int or array of int, default to 0.
*   `code_skipped`   
    Expected code(s) returned by the command if it has no effect, executed will
    not be incremented, int or array of int.   
*   `trap_on_error`   
    Exit immediately  if a commands exits with a non-zero status.      
*   `cwd`   
    Current working directory.   
*   `env`   
    Environment variables, default to `process.env`.   
*   `gid`   
    Unix group id.   
*   `log`   
    Function called with a log related messages.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   
*   `uid`   
    Unix user id.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `executed`   
    Number of executed commands with modifications.   
*   `stdout`   
    Stdout value(s) unless `stdout` option is provided.
*   `stderr`
    Stderr value(s) unless `stderr` option is provided.

## Create a user over SSH:

This example create a user on a remote server with the `useradd` command. It
print the error message if the command failed or an information message if it
succeed.

An exit code equal to "9" defined by the "code_skipped" option indicates that
the command is considered successfull but without any impact.

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
          stdout = []; stderr = []
          if options.stdout
            run.stdout.pipe options.stdout, end: false
          if stds
            run.stdout.on 'data', (data) ->
              if Array.isArray stdout # A string on exit
                stdout.push data
              else console.log 'stdout coming'
          if options.stderr
            run.stderr.pipe options.stderr, end: false
          if stds
            run.stderr.on 'data', (data) ->
              if Array.isArray stderr # A string on exit
                stderr.push data
              else console.log 'stderr coming'
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
                return next err, null, stdout, stderr
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







