
error = require '../utils/error'
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
    'nikita:session:normalize': (action) ->
      # Move property from action to metadata
      if action.hasOwnProperty 'debug'
        action.metadata.debug = action.debug
        delete action.debug
    'nikita:session:action': (action) ->
      debug = action.metadata.debug or false
      unless typeof debug is 'boolean' or debug is 'stdout' or debug instanceof stream.Writable
        throw error 'METADATA_DEBUG_INVALID_VALUE', [
          "configuration `debug` expect a boolean value,"
          "the string \"stdout\", or a Node.js Stream Writer,"
          "got #{JSON.stringify debug}."
        ]
      if debug
        print = (log) ->
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
            if debug is 'stdout'
              process.stdout.write "#{msg}\n"
            else if debug instanceof stream.Writable
              debug.write "#{msg}\n"
            else
              process.stderr.write "#{msg}\n"
        action.operations.events.on 'text', print
        action.operations.events.on 'stdin', print
        action.operations.events.on 'stdout_stream', print
        action.operations.events.on 'stderr_stream', print
