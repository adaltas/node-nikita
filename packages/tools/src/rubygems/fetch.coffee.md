
# `nikita.tools.rubygems.fetch`

Fetch a Ruby gem.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Indicate if a gem was fetch.   
* `filename`   
  Name of the gem file.   
* `filepath`   
  Path of the gem file.   

## Example

```js
require('nikita')
.tools.rubygems.fetch({
  name: 'json',
  version: '2.1.0',
  cwd: '/tmp/my_gems'
}, function(err, {status, filename, filepath}){
  console.log( err ? err.messgage : 'Gem fetched: ' + status);
});
```

## Implementation

We do not support gem returning specification with binary strings because we
couldn't find any suitable parser on NPM.

## Schema

    schema =
      type: 'object'
      properties:
        'cwd':
          type: 'string'
          description: """
          Directory storing gems.
          """
        'gem_bin':
          type: 'string'
          default: 'gem'
          description: """
          Path to the gem command.
          """
        'name':
          type: 'string'
          description: """
          Name of the gem.
          """
        'version':
          type: 'string'
          description: """
          Version of the gem.
          """
      required: ['name']

## Handler

    handler = ({config}) ->
      # log message: "Entering rubygem.fetch", level: 'DEBUG', module: 'nikita/lib/tools/rubygem/fetch'
      # Global Options
      config.ruby ?= {}
      config[k] ?= v for k, v of config.ruby
      # Get version
      unless config.version
        {status, stdout} = await @execute
          cmd: """
          #{config.gem_bin} specification #{config.name} version -r | grep '^version' | sed 's/.*: \\(.*\\)$/\\1/'
          """
          cwd: config.cwd
          shy: true
          bash: config.bash
        config.version = stdout.trim() if status
      config.target = "#{config.name}-#{config.version}.gem"
      # Fetch package
      {status} = await @execute
        cmd: """
        #{config.gem_bin} fetch #{config.name} -v #{config.version}
        """
        cwd: config.cwd
        bash: config.bash
      status: status
      filename: config.target
      filepath: path.resolve config.cwd, config.target

## Export

    module.exports =
      handler: handler
      metadata:
        global: 'ruby'
      schema: schema

## Dependencies

    path = require 'path'
