
# `mecano.tools.git(options, [callback])`

Create and synchronize a git repository.

## Options

*   `source`   
    Git source repository address.   
*   `target`   
    Directory where to clone the repository.   
*   `revision`   
    Git revision, branch or tag.   

## Callback Parameters

*   `err`   
    Error object if any.   
*   `status`   
    Value "true" if repository was created or modified.   

## Example

The following action make sure the git repository is synchronized to the latest
HEAD revision.

```javascript
require('mecano').tools.git({
  source: 'https://github.com/wdavidw/node-mecano.git'
  target: '/tmp/mecano'
}, function(err, synchronized){
  console.log(err ? err.message : 'Repo was synchronized: ' + synchronized);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering git", level: 'DEBUG', module: 'mecano/lib/tools/git'
      # Sanitize parameters
      options.revision ?= 'HEAD'
      # Start real work
      repo_exists = false
      repo_uptodate = false
      @call (_, callback) ->
        fs.exists options.ssh, options.target, (err, exists) ->
          return callback err if err
          repo_exists = exists
          return callback() unless exists # todo, isolate inside call when they receive conditions
          # return callback new Error "Destination not a directory, got #{options.target}" unless stat.isDirectory()
          gitDir = "#{options.target}/.git"
          fs.exists options.ssh, gitDir, (err, exists) ->
            return callback Error "Not a git repository" unless exists
            callback()
      @system.execute
        cmd: "git clone #{options.source} #{options.target}"
        cwd: path.dirname options.target
        unless: -> repo_exists
      @system.execute
        cmd: """
        current=`git log --pretty=format:'%H' -n 1`
        target=`git rev-list --max-count=1 #{options.revision}`
        echo "current revision: $current"
        echo "expected revision: $target"
        if [ $current != $target ]; then exit 3; fi
        """
        # stdout: process.stdout
        cwd: options.target
        trap: true
        code_skipped: 3
        if: -> repo_exists
        shy: true
      , (err, uptodate) ->
        throw err if err
        repo_uptodate = uptodate
      @system.execute
        cmd: "git checkout #{options.revision}"
        cwd: options.target
        unless: -> repo_uptodate

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    misc = require '../misc'
