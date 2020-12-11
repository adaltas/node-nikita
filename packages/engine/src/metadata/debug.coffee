
utils = require '../utils'
stream = require 'stream'

###
Print log information to the console.

Only the logs which type match "text", "stdin", "stdout_stream", "stderr_stream" are handled.

TODO: detect/force isTTY
###

module.exports = ->
  module: '@nikitajs/engine/src/metadata/debug'
  require: '@nikitajs/engine/src/plugins/log'
  hooks:
    'nikita:session:action': (action) ->
      debug = action.metadata.debug or false
      unless typeof debug is 'boolean' or debug is 'stdout' or debug instanceof stream.Writable
        throw utils.error 'METADATA_DEBUG_INVALID_VALUE', [
          "configuration `debug` expect a boolean value,"
          "the string \"stdout\", or a Node.js Stream Writer,"
          "got #{JSON.stringify debug}."
        ]
      unless debug
        action.metadata.debug = false
        return
      debug = action.metadata.debug =
        ws:
          if debug is 'stdout'
            action.metadata.debug.ws = process.stdout
          else if debug instanceof stream.Writable
            action.metadata.debug.ws = debug
          else
            action.metadata.debug.ws = process.stderr
        listener: (log) ->
          unless log.type in ['stdout_stream', 'stderr_stream'] and log.message is null
            msg = if typeof log.message is 'string' then log.message.trim()
            else if typeof log.message is 'number' then log.message
            else if log.message?.toString? then log.message.toString().trim()
            else JSON.stringify log.message
            msg = "[#{log.depth}.#{log.level} #{log.module}] #{ msg}"
            msg = switch log.type
              when 'stdin' then "\x1b[33m#{msg}\x1b[39m"
              when 'stdout_stream' then "\x1b[36m#{msg}\x1b[39m"
              when 'stderr_stream' then "\x1b[35m#{msg}\x1b[39m"
              else "\x1b[32m#{msg}\x1b[39m"
            debug.ws.write "#{msg}\n"
      action.tools.events.addListener 'text', debug.listener
      action.tools.events.addListener 'stdin', debug.listener
      action.tools.events.addListener 'stdout_stream', debug.listener
      action.tools.events.addListener 'stderr_stream', debug.listener
    'nikita:session:result':
      # after: '@nikitajs/engine/src/plugins/log'
      handler: ({action}) ->
        debug = action.metadata.debug
        return unless debug and debug.listener # undefined with invalid value error
        action.tools.events.removeListener 'text', debug.listener
        action.tools.events.removeListener 'stdin', debug.listener
        action.tools.events.removeListener 'stdout_stream', debug.listener
        action.tools.events.removeListener 'stderr_stream', debug.listener
