
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

## Schema

    schema =
      type: 'object'
      properties:
        '':
          type: 'object'
          description: """
          """

## Handler

    handler = ({config}) ->
      # Sanitize config
      config.revision ?= 'HEAD'
      # Start real work
      repo_uptodate = false
      {exists: repo_exists} = await @fs.base.exists target: config.target
      if repo_exists
        # return callback Error "Destination not a directory, got #{config.target}" unless stat.isDirectory()
        gitDir = "#{config.target}/.git"
        {exists: is_git} = await @fs.base.exists ssh: config.ssh, target: gitDir
        throw Error "Not a git repository" unless is_git
      else
        @execute
          cmd: "git clone #{config.source} #{config.target}"
          cwd: path.dirname config.target
      {status: repo_uptodate} = await @execute
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
      unless repo_uptodate
        @execute
          cmd: "git checkout #{config.revision}"
          cwd: config.target

## Exports

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    path = require 'path'
