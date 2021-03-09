
# `nikita.log.md`

Write log to the host filesystem in Markdown.

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
      ]

## Handler

    handler = ({config}) ->
      state = last_event_type: undefined
      await @call $: log_fs, config, serializer:
        'nikita:action:start': ({action}) ->
          content = []
          content.push "\nEntering #{action.metadata.module} (#{(action.metadata.position.map (index) -> index + 1).join '.'})\n" if action.metadata.module
          return content.join '' unless action.metadata.header
          {last_event_type} = state
          state.last_event_type = 'nikita:action:start'
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
          state.last_event_type = 'stdout_stream'
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
          state.last_event_type = 'text'
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
