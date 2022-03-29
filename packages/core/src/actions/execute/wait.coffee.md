
# `nikita.execute.wait`

Run a command periodically and continue once the command succeed. Status will be
set to "false" if the user command succeed right away, considering that no
change had occured. Otherwise it will be set to "true".   

## Example

```js
const {$status} = await nikita.execute.wait({
  command: "test -f /tmp/sth"
})
console.info(`Command succeed, the file "/tmp/sth" now exists: ${$status}`)
```

## Hooks

    on_action = ({config}) ->
      # Command is required but let the schema throw an error
      return unless config.command
      config.command = [config.command] if typeof config.command is 'string'
      # Always normalise quorum as an integer
      if config.quorum and config.quorum is true
        config.quorum = Math.ceil (config.command.length + 1) / 2
      else unless config.quorum?
        config.quorum = config.command.length

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'quorum':
            type: ['integer', 'boolean']
            description: '''
            Number of minimal successful connection, 50%+1 if "true".
            '''
          'command':
            type: 'array'
            items: type: 'string'
            description: '''
            The commands to be executed.
            '''
          'interval':
            type: 'integer'
            default: 2000
            description: '''
            Time interval in milliseconds between which we should wait before
            re-executing the command, default to 2s.
            '''
          'code':
            $ref: 'module://@nikitajs/core/src/actions/execute#/definitions/config/properties/code'
            default: {}
          'retry':
            type: 'integer'
            default: -1
            description: '''
            Maximum number of attempts.
            '''
          'stdin_log':
            $ref: 'module://@nikitajs/core/src/actions/execute#/definitions/config/properties/stdin_log'
          'stdout_log':
            $ref: 'module://@nikitajs/core/src/actions/execute#/definitions/config/properties/stdout_log'
          'stderr_log':
            $ref: 'module://@nikitajs/core/src/actions/execute#/definitions/config/properties/stderr_log'
        required: ['command']

## Handler

    handler = ({config, tools: {log}}) ->
      attempts = 0
      $status = false
      wait = (timeout) ->
        return unless timeout
        new Promise (resolve) ->
          setTimeout resolve, timeout
      commands = config.command
      while attempts isnt config.retry
        attempts++
        log message: "Start attempt ##{attempts}", level: 'DEBUG'
        commands = await utils.promise.array_filter commands, (command) =>
          {$status: success} = await @execute
            command: command
            code: config.code
            stdin_log: config.stdin_log
            stdout_log: config.stdout_log
            stderr_log: config.stderr_log
            $relax: config.code.false.length is 0
          !success
        log message: "Attempt ##{attempts}, expect #{config.quorum} success to reach the quorum, got #{config.command.length - commands.length}", level: 'INFO'
        if commands.length <= config.command.length - config.quorum
          return
            attempts: attempts
            $status: attempts > 1
        await wait config.interval
      throw utils.error 'NIKITA_EXECUTE_WAIT_MAX_RETRY', [
        'the number of attempts reached the maximum number of retries,'
        "got #{config.retry}."
      ]

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        argument_to_config: 'command'
        definitions: definitions

## Dependencies

    utils = require '../../utils'
