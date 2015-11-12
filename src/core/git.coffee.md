
# `git(options, callback)`

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
require('mecano').git({
  source: 'https://github.com/wdavidw/node-mecano.git'
  destination: '/tmp/mecano'
}, function(err, synchronized){
  console.log(err ? err.message : 'Repo was synchronized: ' + synchronized);
});
```

## Source Code

    module.exports = (options, callback) ->
      # Sanitize parameters
      options.revision ?= 'HEAD'
      # Start real work
      repo_exists = false
      repo_uptodate = false
      @
      .call (_, callback) ->
        fs.exists options.ssh, options.destination, (err, exists) ->
          return callback err if err
          repo_exists = exists
          return callback() unless exists # todo, isolate inside call when they receive conditions
          # return callback new Error "Destination not a directory, got #{options.destination}" unless stat.isDirectory()
          gitDir = "#{options.destination}/.git"
          fs.exists options.ssh, gitDir, (err, exists) ->
            return callback Error "Not a git repository" unless exists
            callback()
      .execute
        cmd: "git clone #{options.source} #{options.destination}"
        cwd: path.dirname options.destination
        unless: -> repo_exists
      .execute
        cmd: """
        current=`git log --pretty=format:'%H' -n 1`
        target=`git rev-list --max-count=1 #{options.revision}`
        echo "current revision: $current"
        echo "expected revision: $target"
        if [ $current != $target ]; then exit 3; fi
        """
        # stdout: process.stdout
        cwd: options.destination
        trap_on_error: true
        code_skipped: 3
        if: -> repo_exists
        shy: true
      , (err, uptodate) ->
        throw err if err
        repo_uptodate = uptodate
      .execute
        cmd: "git checkout #{options.revision}"
        cwd: options.destination
        unless: -> repo_uptodate
      .then (err, status) ->
        callback err, status

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    misc = require '../misc'
