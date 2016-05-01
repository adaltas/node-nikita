
# `execute(options, callback)`

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
*   `code` (int|string|array)   
    Expected code(s) returned by the command, int or array of int, default to 0.   
*   `code_skipped` (int|string|array)   
    Expected code(s) returned by the command if it has no effect, executed will
    not be incremented, int or array of int.   
*   `trap`   
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
*   `stdout_callback` (boolean)
    pass stdout output to the callback as fourth argument, default is "true".   
*   `stdout_log` (boolean)
    pass stdout output to the logs of type "stdout_stream", default is "true".   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   
*   `stderr_callback` (boolean)
    pass stderr output to the callback as fourth argument, default is "true".   
*   `stderr_log` (boolean)
    pass stdout output to the logs of type "stdout_stream", default is "true".   
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
  cmd: 'useradd myfriend'
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

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering execute", level: 'DEBUG', module: 'mecano/lib/execute'
      stds = options.user_args
      # Validate parameters
      options.cmd = options.argument if typeof options.argument is 'string'
      options.code ?= [0]
      options.code = [options.code] unless Array.isArray options.code
      options.code_skipped ?= []
      options.code_skipped = [options.code_skipped] unless Array.isArray options.code_skipped
      options.stdout_callback = true if options.stdout_callback is undefined
      options.stderr_callback = true if options.stderr_callback is undefined
      options.stdout_log ?= false
      options.stderr_log ?= false
      options.cmd = options.cmd.call @, options if typeof options.cmd is 'function'
      throw Error "Missing cmd: #{options.cmd}" unless options.cmd?
      if options.trap
        options.cmd = "set -e\n#{options.cmd}"
      # options.log message: "Command is: `#{options.cmd}`", level: 'INFO', module: 'mecano/lib/execute'
      options.log message: options.cmd, type: 'stdin', module: 'mecano/lib/execute'
      child = exec options
      stdout = []; stderr = []
      child.stdout.pipe options.stdout, end: false if options.stdout
      child.stderr.pipe options.stderr, end: false if options.stderr
      stdout_stream_open = stderr_stream_open = false
      if options.stdout_callback or options.stdout_log
        child.stdout.on 'data', (data) ->
          stdout_stream_open = true unless options.stdout is false or options.stdout is null
          options.log message: data, type: 'stdout_stream', module: 'mecano/lib/execute' unless options.stdout is false or options.stdout is null
          if options.stdout_callback
            if Array.isArray stdout # A string on exit
              stdout.push data
            else console.log 'stdout coming after child exit'
      if options.stderr_callback or stderr_log
        child.stderr.on 'data', (data) ->
          stderr_stream_open = true unless options.stdout is false or options.stdout is null
          options.log message: data, type: 'stderr_stream', module: 'mecano/lib/execute' unless options.stderr is false or options.stderr is null
          if options.stderr_callback
            if Array.isArray stderr # A string on exit
              stderr.push data
            else console.log 'stderr coming after child exit'
      child.on "exit", (code) ->
        # Give it some time because the "exit" event is sometimes
        # called before the "stdout" "data" event when runing
        # `npm test`
        setTimeout ->
          options.log message: null, type: 'stdout_stream', module: 'mecano/lib/execute' if stdout_stream_open and not (options.stdout is false or options.stdout is null)
          options.log message: null, type: 'stderr_stream', module: 'mecano/lib/execute' unless  stderr_stream_open and not (options.stderr is false or options.stderr is null)
          stdout = stdout.map((d) -> d.toString()).join('')
          stderr = stderr.map((d) -> d.toString()).join('')
          options.log message: stdout, type: 'stdout', module: 'mecano/lib/execute' if stdout and stdout isnt '' unless options.stdout is false or options.stdout is null
          options.log message: stderr, type: 'stderr', module: 'mecano/lib/execute' if stderr and stderr isnt '' unless options.stderr is false or options.stderr is null
          if options.stdout
            child.stdout.unpipe options.stdout
          if options.stderr
            child.stderr.unpipe options.stderr
          if options.code.indexOf(code) is -1 and options.code_skipped.indexOf(code) is -1
            err = new Error "Invalid Exit Code: #{code}"
            err.code = code
            return callback err, null, stdout, stderr
          if options.code_skipped.indexOf(code) is -1
            executed = true
          else
            options.log message: "Skip exit code \"#{code}\"", level: 'INFO', module: 'mecano/lib/execute'
          callback null, executed, stdout, stderr, code
        , 1

## Dependencies

    exec = require 'ssh2-exec'
    misc = require '../misc'
