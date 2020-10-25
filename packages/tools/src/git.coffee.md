
# `nikita.tools.git`

Create and synchronize a git repository.

## Options

* `source`   
  Git source repository address.   
* `target`   
  Directory where to clone the repository.   
* `revision`   
  Git revision, branch or tag.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value "true" if repository was created or modified.   

## Example

The following action make sure the git repository is synchronized to the latest
HEAD revision.

```javascript
require('nikita')
.tools.git({
  source: 'https://github.com/wdavidw/node-nikita.git'
  target: '/tmp/nikita'
}, function(err, {status}){
  console.info(err ? err.message : 'Repo was synchronized: ' + status);
});
```

## Source Code

    module.exports = ({config}) ->
      @log message: "Entering git", level: 'DEBUG', module: 'nikita/lib/tools/git'
      # SSH connection
      ssh = @ssh config.ssh
      # Sanitize config
      config.revision ?= 'HEAD'
      # Start real work
      repo_exists = false
      repo_uptodate = false
      @call (_, callback) ->
        @fs.exists ssh: config.ssh, target: config.target, (err, {exists}) ->
          return callback err if err
          repo_exists = exists
          return callback() unless exists # todo, isolate inside call when they receive conditions
          # return callback Error "Destination not a directory, got #{config.target}" unless stat.isDirectory()
          gitDir = "#{config.target}/.git"
          @fs.exists ssh: config.ssh, target: gitDir, (err, {exists}) ->
            return callback Error "Not a git repository" unless exists
            callback()
      @execute
        cmd: "git clone #{config.source} #{config.target}"
        cwd: path.dirname config.target
        unless: -> repo_exists
      @execute
        cmd: """
        current=`git log --pretty=format:'%H' -n 1`
        target=`git rev-list --max-count=1 #{config.revision}`
        echo "current revision: $current"
        echo "expected revision: $target"
        if [ $current != $target ]; then exit 3; fi
        """
        # stdout: process.stdout
        cwd: config.target
        trap: true
        code_skipped: 3
        if: -> repo_exists
        shy: true
      , (err, {status}) ->
        throw err if err
        repo_uptodate = status
      @execute
        cmd: "git checkout #{config.revision}"
        cwd: config.target
        unless: -> repo_uptodate

## Dependencies

    path = require 'path'
