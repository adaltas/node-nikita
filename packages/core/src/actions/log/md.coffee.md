
# `nikita.log.md`

Write log to the host filesystem in Markdown.

## Example

```js
nikita(async function(){
  await this.log.md({
    basedir: './logs',
    filename: 'nikita.log'
  })
  await this.call(({tools: {log}}) => {
    log({message: 'hello'})
  })
})
```

## Hook

    on_action = ({config}) ->
      config.serializer = {}

## Schema

    schema =
      type: 'object'
      allOf: [
        $ref: 'module://@nikitajs/core/src/actions/log/fs'
        properties:
          divider:
            type: 'string'
            default: ' : '
            description: """
            The characters used to join the hierarchy of headers to create a
            markdown header.
            """
          enter:
            type: 'boolean'
            default: true
            description: '''
            Enable or disable the entering messages.
            '''
      ]

## Handler

    handler = ({config}) ->
      state = {}
      await @call $: log_fs, config, serializer:
        'diff': (log) ->
          "\n```diff\n#{log.message}```\n" if log.message
        'nikita:action:start': ({action}) ->
          act = action.parent
          bastard = undefined
          while act
            bastard = act.metadata.bastard
            break if bastard isnt undefined
            act = act.parent
          content = []
          if config.enter and action.metadata.module and action.metadata.log isnt false and bastard isnt true
            content.push [
              '\n'
              'Entering'
              ' '
              "#{action.metadata.module}"
              ' '
              '('
              "#{(action.metadata.position.map (index) -> index + 1).join '.'}"
              ')'
              '\n'
            ].join ''
          return content.join '' unless action.metadata.header
          walk = (parent) ->
            precious = parent.metadata.header
            results = []
            results.push precious unless precious is undefined
            results.push ...(walk parent.parent) if parent.parent
            results
          headers = walk action
          header = headers.reverse().join config.divider
          content.push '\n'
          content.push '#'.repeat headers.length
          content.push " #{header}\n"
          content.join ''
        'stdin': (log) ->
          out = []
          if log.message.indexOf('\n') is -1
          then out.push "\nRunning Command: `#{log.message}`\n"
          else out.push "\n```stdin\n#{log.message}\n```\n"
          out.join ''
        'stderr': (log) ->
          "\n```stderr\n#{log.message}```\n"
        'stdout_stream': (log) ->
          if log.message is null
            state.stdout_count = 0
          else if state.stdout_count is undefined
            state.stdout_count = 1
          else
            state.stdout_count++
          out = []
          out.push '\n```stdout\n' if state.stdout_count is 1
          out.push log.message if state.stdout_count > 0
          out.push '\n```\n' if state.stdout_count is 0
          out.join ''
        'text': (log) ->
          content = []
          content.push "\n#{log.message}"
          content.push " (#{log.depth}.#{log.level}, written by #{log.module})" if log.module and log.module isnt '@nikitajs/core/src/actions/call'
          content.push "\n"
          content.join ''

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema
      ssh: false

## Dependencies

    log_fs = require './fs'
