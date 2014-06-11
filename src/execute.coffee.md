
`exec` `execute([goptions], options, callback)`
-----------------------------------------------

Run a command locally or with ssh if `host` or `ssh` is provided.

    each = require 'each'
    exec = require 'ssh2-exec'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'

`options`           Command options include:
*   `cmd`           String, Object or array; Command to execute.
*   `code`          Expected code(s) returned by the command, int or array of int, default to 0.
*   `code_skipped`  Expected code(s) returned by the command if it has no effect, executed will not be incremented, int or array of int.
*   `cwd`           Current working directory.
*   `env`           Environment variables, default to `process.env`.
*   `gid`           Unix group id.
*   `log`           Function called with a log related messages.
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.
*   `stdout`        Writable Stream in which commands output will be piped.
*   `stderr`        Writable Stream in which commands error will be piped.
*   `uid`           Unix user id.

`callback`          Received parameters are:
*   `err`           Error if any enriched with the "code" property.
*   `executed`      Number of executed commandes.
*   `stdout`        Stdout value(s) unless `stdout` option is provided.
*   `stderr`        Stderr value(s) unless `stderr` option is provided.

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      result = child()
      finish = (err, created, stdout, stderr) ->
        callback err, created, stdout, stderr if callback
        result.end err, created
      isArray = Array.isArray options
      misc.options options, (err, options) ->
        return finish err if err
        executed = 0
        stdouts = []
        stderrs = []
        escape = (cmd) ->
          esccmd = ''
          for char in cmd
            if char is '$'
              esccmd += '\\'
            esccmd += char
          esccmd
        stds = if callback then callback.length > 2 else false
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, i, next) ->
          # Validate parameters
          options = { cmd: options } if typeof options is 'string'
          return next new Error "Missing cmd: #{options.cmd}" unless options.cmd?
          options.code ?= [0]
          options.code = [options.code] unless Array.isArray options.code
          options.code_skipped ?= []
          options.code_skipped = [options.code_skipped] unless Array.isArray options.code_skipped
          # Start real work
          cmd = () ->
            options.log? "Execute: #{options.cmd}"
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
                stdouts.push if stds then stdout.join('') else undefined
                stderrs.push if stds then stderr.join('') else undefined
                if options.stdout
                  run.stdout.unpipe options.stdout
                if options.stderr
                  run.stderr.unpipe options.stderr
                if options.code.indexOf(code) is -1 and options.code_skipped.indexOf(code) is -1
                  err = new Error "Invalid exec code #{code}"
                  err.code = code
                  return next err
                executed++ if options.code_skipped.indexOf(code) is -1
                next()
              , 1
          conditions.all options, next, cmd
        .on 'both', (err) ->
          stdouts = stdouts[0] unless isArray
          stderrs = stderrs[0] unless isArray
          finish err, executed, stdouts, stderrs
      result