
# `nikita.system.chmod`

Change the permissions of a file or directory.

## config

* `mode`   
  Permissions of the file or the parent directory.   
* `stats` (Stat instance, optional)   
  Pass the Stat object relative to the target file or directory, to be
  used as an optimization.     
* `target`   
  Where the file or directory is copied.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file permissions was created or modified.   

## Example

```js
require('nikita')
.system.chmod({
  target: '~/my/project',
  mode: 0o755
}, function(err, status){
  console.log(err ? err.message : 'File was modified: ' + status);
});
```

## Source Code

    handler = ({config}) ->
      @log message: "Entering chmod", level: 'DEBUG', module: 'nikita/lib/system/chmod'
      if config.stat
        console.log 'Deprecated Option: receive config.stat instead of config.stats in system.chmod'
        config.stats = config.stat
      # SSH connection
      ssh = @ssh config.ssh
      # Validate parameters
      throw Error "Missing target: #{JSON.stringify config.target}" unless config.target
      throw Error "Missing option 'mode'" unless config.mode
      @call
        unless: !!config.stats # Option 'stat' short-circuit
      , (_, callback) ->
        @log message: "Stat information: \"#{config.target}\"", level: 'DEBUG', module: 'nikita/lib/system/chmod'
        @fs.base.stat
          target: config.target
        , (err, {stats}) ->
          config.stats = stats unless err
          callback err
      @call ({}, callback) ->
        # Detect changes
        if misc.mode.compare config.stats.mode, config.mode
          @log message: "Identical permissions on \"#{config.target}\"", level: 'INFO', module: 'nikita/lib/system/chmod'
          return callback()
        # Apply changes
        @fs.base.chmod target: config.target, mode: config.mode, sudo: config.sudo, (err) ->
          @log message: "Change permissions from \"#{config.stats.mode.toString 8}\" to \"#{config.mode.toString 8}\" on \"#{config.target}\"", level: 'WARN', module: 'nikita/lib/system/chmod'
          callback err, true

## Exports

    module.exports
      handler: handler
      schema: schema

## Dependencies

    misc = require '../misc'
