
# `nikita.system.execute(options, [callback])`

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

* `arch_chroot` (boolean|string)   
  Run this command inside a root directory with the arc-chroot command or any
  provided string, require the "rootdir" option if activated.
* `bash` (boolean|string)   
  Serialize the command into a file and execute it with bash.
* `rootdir` (string)   
  Path to the mount point corresponding to the root directory, required if
  the "arch_chroot" option is activated.
* `cmd`   
  String, Object or array; Command to execute.
* `code` (int|string|array)   
  Expected code(s) returned by the command, int or array of int, default to 0.
* `code_skipped` (int|string|array)   
  Expected code(s) returned by the command if it has no effect, executed will
  not be incremented, int or array of int.
* `dirty` (boolean)   
  Leave temporary files on the filesystem.
* `trap`   
  Exit immediately if a commands exits with a non-zero status.
* `cwd`   
  Current working directory.
* `env`   
  Environment variables, default to `process.env`.
* `gid`   
  Unix group id.
* `log`   
  Function called with a log related messages.
* `stdin_log` (boolean)   
  Log the executed command of type stdin, default is "true".
* `stdout` (stream.Writable)   
  Writable EventEmitter in which the standard output of executed commands will
  be piped.
* `stdout_callback` (boolean)   
  Pass stdout output to the callback as fourth argument, default is "true".
* `stdout_log` (boolean)   
  Pass stdout output to the logs of type "stdout_stream", default is "true".
* `stdout_trim` (boolean)   
  Trim stdout argument passed in the callback.
* `stderr` (stream.Writable)   
  Writable EventEmitter in which the standard error output of executed command
  will be piped.
* `stderr_callback` (boolean)   
  Pass stderr output to the callback as fourth argument, default is "true".
* `stderr_log` (boolean)   
  Pass stdout output to the logs of type "stdout_stream", default is "true".
* `stderr_trim` (boolean)   
  Trim stderr argument passed in the callback.
* `sudo` (boolean)   
  Run a command as sudo, desactivated if user is "root".
* `target` (string)   
  Temporary path storing the script, only apply with the bash and arch_chroot options, always disposed once executed.
* `uid`   
  Unix user id.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  Value is "true" if command exit equals option "code", "0" by default, "false" if
  command exit equals option "code_skipped", none by default.
* `stdout`   
  Stdout value(s) unless `stdout` option is provided.
* `stderr`   
  Stderr value(s) unless `stderr` option is provided.

## Create a user over SSH:

This example create a user on a remote server with the `useradd` command. It
print the error message if the command failed or an information message if it
succeed.

An exit code equal to "9" defined by the "code_skipped" option indicates that
the command is considered successfull but without any impact.

```javascript
nikita.system.execute({
  ssh: ssh,
  cmd: 'useradd myfriend',
  code_skipped: 9
}, function(err, created){
  if(err) return;
  if(created){
    console.log('User created');
  }else{
    console.log('User already exists');
  }
});
```

## Run a command with bash

```javascript
nikita.system.execute({
  bash: true,
  cmd: 'env'
}, function(err, status, stdout, stderr){
  console.log(err || stdout);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering execute", level: 'DEBUG', module: 'nikita/lib/system/execute'
      # SSH connection
      ssh = @ssh options.ssh
      # Validate parameters
      options.cmd = options.argument if typeof options.argument is 'string'
      options.code ?= [0]
      options.code = [options.code] unless Array.isArray options.code
      options.code_skipped ?= []
      options.code_skipped = [options.code_skipped] unless Array.isArray options.code_skipped
      options.stdin_log ?= true
      options.stdout_log ?= true
      options.stderr_log ?= true
      options.stdout_callback = true if options.stdout_callback is undefined
      options.stderr_callback = true if options.stderr_callback is undefined
      options.cmd = options.cmd.call @, options if typeof options.cmd is 'function'
      options.bash = 'bash' if options.bash is true
      options.arch_chroot = 'arch-chroot' if options.arch_chroot is true
      options.cmd = "set -e\n#{options.cmd}" if options.cmd and options.trap
      options.cmd_original = "#{options.cmd}"
      throw Error "Required Option: the \"cmd\" option is not provided" unless options.cmd?
      throw Error "Incompatible Options: bash, arch_chroot" if ['bash', 'arch_chroot'].filter((k) -> options[k]).length > 1
      throw Error "Required Option: \"rootdir\" with \"arch_chroot\"" if options.arch_chroot and not options.rootdir
      throw Error "Invalid Option: the \"target\" option requires either one of the \"bash\" or \"arch_chroot\" options" if options.target and not ['bash', 'arch_chroot'].filter((k) -> options[k]).length
      result = stdout: null, stderr: null, code: null
      # Guess current username
      current_username =
        if ssh then ssh.config.username
        else if /^win/.test(process.platform) then process.env['USERPROFILE'].split(path.sep)[2]
        else process.env['USER']
      # Sudo
      @call ->
        return unless options.sudo
        return options.sudo = false if current_username is 'root'
        options.bash = 'bash' unless ['bash', 'arch_chroot'].some (k) -> options[k]
      # User substitution
      # Determines if writing is required and eventually convert uid to username
      @call shy: true, (_, callback)->
        return callback null, false unless options.uid
        return callback null, false if current_username is 'root'
        return callback null, options.uid isnt current_username unless /\d/.test "#{options.uid}"
        @system.execute "awk -v val=#{options.uid} -F ":" '$3==val{print $1}' /etc/passwd`", (err, _, stdout) ->
          options.uid = stdout.trim() unless err
          options.bash = 'bash' unless options.bash or options.arch_chroot
          callback err, options.uid isnt current_username
      # Write script
      @call
        if: -> options.bash
      , ->
        cmd = options.cmd
        options.target = "/tmp/nikita_#{string.hash options.cmd}" if typeof options.target isnt 'string'
        options.log message: "Writing bash script to #{JSON.stringify options.target}", level: 'INFO'
        options.cmd = "#{options.bash} #{options.target}"
        options.cmd = "su - #{options.uid} -c '#{options.cmd}'" if options.uid
        @fs.writeFile
          target: options.target
          content: cmd
          uid: options.uid
          sudo: false
      @call
        if: -> options.arch_chroot
      , ->
        cmd = options.cmd
        options.target = "/var/tmp/nikita_#{string.hash options.cmd}" if typeof options.target isnt 'string'
        options.log message: "Writing arch-chroot script to #{JSON.stringify options.target}", level: 'INFO'
        options.cmd = "arch-chroot #{options.rootdir} bash #{options.target}"
        @fs.writeFile
          target: "#{path.join options.rootdir, options.target}"
          content: "#{cmd}"
          mode: options.mode
          sudo: false
      @call ->
        return unless options.sudo
        options.cmd = "sudo #{options.cmd}" if options.sudo
      # Execute
      @call (_, callback) ->
        options.log message: options.cmd_original, type: 'stdin', level: 'INFO', module: 'nikita/lib/system/execute' if options.stdin_log
        child = exec options, ssh: ssh
        result.stdout = []; result.stderr = []
        child.stdout.pipe options.stdout, end: false if options.stdout
        child.stderr.pipe options.stderr, end: false if options.stderr
        stdout_stream_open = stderr_stream_open = false
        if options.stdout_callback or options.stdout_log
          child.stdout.on 'data', (data) ->
            stdout_stream_open = true if options.stdout_log
            options.log message: data, type: 'stdout_stream', module: 'nikita/lib/system/execute' if options.stdout_log
            if options.stdout_callback
              if Array.isArray result.stdout # A string on exit
                result.stdout.push data
              else console.log 'stdout coming after child exit'
        if options.stderr_callback or options.stderr_log
          child.stderr.on 'data', (data) ->
            stderr_stream_open = true if options.stderr_log
            options.log message: data, type: 'stderr_stream', module: 'nikita/lib/system/execute' if options.stderr_log
            if options.stderr_callback
              if Array.isArray result.stderr # A string on exit
                result.stderr.push data
              else console.log 'stderr coming after child exit'
        child.on "exit", (code) ->
          result.code = code
          # Give it some time because the "exit" event is sometimes
          # called before the "stdout" "data" event when runing
          # `npm test`
          setTimeout ->
            options.log message: null, type: 'stdout_stream', module: 'nikita/lib/system/execute' if stdout_stream_open and options.stdout_log
            options.log message: null, type: 'stderr_stream', module: 'nikita/lib/system/execute' if  stderr_stream_open and options.stderr_log
            result.stdout = result.stdout.map((d) -> d.toString()).join('')
            result.stdout = result.stdout.trim() if options.trim or options.stdout_trim
            result.stderr = result.stderr.map((d) -> d.toString()).join('')
            result.stderr = result.stderr.trim() if options.trim or options.stderr_trim
            options.log message: result.stdout, type: 'stdout', module: 'nikita/lib/system/execute' if result.stdout and result.stdout isnt '' and options.stdout_log
            options.log message: result.stderr, type: 'stderr', module: 'nikita/lib/system/execute' if result.stderr and result.stderr isnt '' and options.stderr_log
            if options.stdout
              child.stdout.unpipe options.stdout
            if options.stderr
              child.stderr.unpipe options.stderr
            if options.code.indexOf(code) is -1 and options.code_skipped.indexOf(code) is -1
              err = Error "Invalid Exit Code: #{code}"
              err.code = code
              return callback err, null
            if options.code_skipped.indexOf(code) is -1
              status = true
            else
              options.log message: "Skip exit code \"#{code}\"", level: 'INFO', module: 'nikita/lib/system/execute'
            callback null, status
          , 1
      @next (err1, status) ->
        @system.remove
          if: not options.dirty and options.target
          target: options.target
          always: true # todo, need to create this option (run even on error)
        @next (err2) ->
          callback err1 or err2, status, result.stdout, result.stderr, result.code

## Dependencies

    path = require 'path'
    exec = require 'ssh2-exec'
    misc = require '../../misc'
    string = require '../../misc/string'
