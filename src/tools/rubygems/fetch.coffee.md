
# `nikita.tools.gem.fetch(options, [callback])`

Fetch a Ruby gem.

## Options

* `cwd` (string)   
  Directory storing gems.
* `gem_bin` (string)   
  Path to the gem command, default to 'gem'
* `name` (string)   
  Name of the gem, required.   
* `version` (string)   
  Version of the gem.

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  Indicate if a gem was fetch.   
* `filename`   
  Name of the gem file.   
* `filepath`   
  Path of the gem file.   

## Exemple

```js
require('nikita')
.tools.rubygems.fetch({
  name: 'json',
  version: '2.1.0',
  cwd: '/tmp/my_gems'
}, function(err, status, filename, filepath){
  console.log( err ? err.messgage : 'Gem fetched: ' + status);
});
```

## Source code

    module.exports = (options, callback) ->
      options.log message: "Entering rubygem.fetch", level: 'DEBUG', module: 'nikita/lib/tools/rubygem/fetch'
      options.gem_bin ?= 'gem'
      @system.execute
        unless: options.version
        cmd: """
        gem specification json version -r | grep -v '^\\-\\-\\-' | sed 's/.*: \\(.*\\)$/\\1/'
        """
        cwd: options.cwd
        shy: true
      , (err, status, stdout) ->
        throw err if err
        options.version = stdout.trim() if status
        options.target = "#{options.name}-#{options.version}.gem"
      @call ->
        @system.execute
          cmd: """
          #{options.gem_bin} fetch #{options.name} -v #{options.version}
          """
          cwd: options.cwd
      @then (err, status) ->
        callback err, status, options.target, path.resolve options.cwd, options.target

## Dependencies

    path = require 'path'
