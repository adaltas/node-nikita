
# `nikita.wait.execute`

Run a command periodically and continue once the command succeed. Status will be
set to "false" if the user command succeed right away, considering that no
change had occured. Otherwise it will be set to "true".   

## Example

```js
require('nikita')
.wait.execute({
  cmd: "test -f /tmp/sth"
}, function(err, {status}){
  // Command succeed, the file "/tmp/sth" now exists
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'quorum':
          type: ['integer', 'boolean']
          description: """
          Number of minimal successful connection, 50%+1 if "true".
          """
        'cmd':
          oneOf: [
            type: 'string'
          ,
            type: 'array'
            items: type: 'string'
          ]
          description: """
          The commands to be executed.
          """
        'interval':
          type: 'integer'
          default: 2000
          description: """
          Time interval between which we should wait before re-executing the command,
          default to 2s.
          """
        'code':
          oneOf: [
            type: 'integer'
          ,
            type: 'array'
            items: type: 'integer'
          ]
          description: """
          Expected exit code to recieve to exit and call the user callback, default to "0".
          """
        'code_skipped':
          oneOf: [
            type: 'integer'
          ,
            type: 'array'
            items: type: 'integer'
          ]
          default: 1
          description: """
          Expected code to be returned when the command failed and should be scheduled
          for later execution, default to "1".
          """

        'stdin_log':
          $ref: 'module://@nikitajs/engine/src/actions/execute#/properties/stdin_log'
        'stdout_log':
          $ref: 'module://@nikitajs/engine/src/actions/execute#/properties/stdout_log'
        'stderr_log':
          $ref: 'module://@nikitajs/engine/src/actions/execute#/properties/stderr_log'
      required: ['cmd']

## Source Code

    handler = ({config, metadata, tools: {log}}, callback) ->
      # Validate parameters
      config.cmd = [config.cmd] unless Array.isArray config.cmd
      if config.quorum and config.quorum is true
        config.quorum = Math.ceil config.cmd.length / 2
      else unless config.quorum?
        config.quorum = config.cmd.length
      quorum_current = 0
      modified = false
      for cmd in config.cmd
        count = 0
        break if quorum_current >= config.quorum
        run = =>
          count++
          log message: "Attempt ##{count}", level: 'INFO', module: 'nikita/lib/wait/execute'
          {status} = await @execute
            cmd: cmd
            code: config.code or 0
            code_skipped: config.code_skipped
            stdin_log: config.stdin_log
            stdout_log: config.stdout_log
            stderr_log: config.stderr_log
          if not status
            return new Promise (resolve) ->
              setTimeout ->
                await run()
                resolve()
              , config.interval
          log message: "Finish wait for execution", level: 'INFO', module: 'nikita/lib/wait/execute'
          quorum_current++
          modified = true if count > 1
        await run()
      status: modified

## Exports

    module.exports =
      handler: handler
      metadata:
        argument: 'cmd'
      schema: schema

## Dependencies

    each = require 'each'
