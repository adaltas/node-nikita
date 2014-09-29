
# `git(options, [goptions], callback`

Create and synchronize a git repository.

## Options

*   `source`   
    Git source repository address.   
*   `destination`   
    Directory where to clone the repository.   
*   `revision`   
    Git revision, branch or tag.   
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
*   `synchronized`   
    Number of git actions with modifications.   

## Example

The following action make sure the git repository is synchronized to the latest
HEAD revision.

```javascript
require('mecano').extract({
  source: 'https://github.com/wdavidw/node-mecano.git'
  destation: '/tmp/mecano'
}, function(err, synchronized){
  console.log(err ? err.message : 'Repo was synchronized: ' + synchronized);
});
```


    module.exports = (goptions, options, callback) ->
      wrap arguments, (options, next) ->
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
            next null, true
        prepare()

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    misc = require './misc'
    wrap = require './misc/wrap'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'








