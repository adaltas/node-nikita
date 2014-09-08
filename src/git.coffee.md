
`git([goptions], options, callback`
-----------------------------------

Create and synchronize a git repository.

`options`           Command options include:   
*   `source`        Git source repository address.   
*   `destination`   Directory where to clone the repository.   
*   `revision`      Git revision, branch or tag.   
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
*   `stdout`        Writable EventEmitter in which command output will be piped.   
*   `stderr`        Writable EventEmitter in which command error will be piped.   


    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      misc.options options, (err, options) ->
        return callback err if err
        updated = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          # Sanitize parameters
          options.revision ?= 'HEAD'
          rev = null
          # Start real work
          prepare = ->
            fs.exists options.ssh, options.destination, (err, exists) ->
              return next err if err
              return clone() unless exists
              # return next new Error "Destination not a directory, got #{options.destination}" unless stat.isDirectory()
              gitDir = "#{options.destination}/.git"
              fs.exists options.ssh, gitDir, (err, exists) ->
                return next new Error "Not a git repository" unless exists
                log()
          clone = ->
            execute
              ssh: options.ssh
              cmd: "git clone #{options.source} #{options.destination}"
              cwd: path.dirname options.destination
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed, stdout, stderr) ->
              return next err if err
              checkout()
          log = ->
            execute
              ssh: options.ssh
              cmd: "git log --pretty=format:'%H' -n 1"
              cwd: options.destination
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed, stdout, stderr) ->
              return next err if err
              current = stdout.trim()
              execute
                ssh: options.ssh
                cmd: "git rev-list --max-count=1 #{options.revision}"
                cwd: options.destination
                log: options.log
                stdout: options.stdout
                stderr: options.stderr
              , (err, executed, stdout, stderr) ->
                return next err if err
                if stdout.trim() isnt current
                then checkout()
                else next()
          checkout = ->
            execute
              ssh: options.ssh
              cmd: "git checkout #{options.revision}"
              cwd: options.destination
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err) ->
              return next err if err
              updated++
              next()
          conditions.all options, next, prepare
        .on 'both', (err) ->
          callback err, updated

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'








