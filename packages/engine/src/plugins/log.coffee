
{EventEmitter} = require 'events'
stackTrace = require 'stack-trace'
path = require 'path'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/log'
  require: '@nikitajs/engine/src/plugins/events'
  hooks:
    'nikita:session:action':
      after: '@nikitajs/engine/src/plugins/events'
      handler: (action) ->
        action.log = (log) ->
          # log.message = log.message
          log.level ?= 'INFO'
          log.time ?= Date.now()
          log.index ?= action.metadata.index
          log.module ?= action.metadata.module
          log.namespace ?= action.metadata.namespace
          log.type ?= 'text'
          log.depth = action.metadata.depth
          log.metadata = action.metadata
          log.config = action.config
          frame = stackTrace.get()[1]
          log.filename = frame.getFileName()
          log.file = path.basename(frame.getFileName())
          log.line = frame.getLineNumber()
          if action.metadata.debug
            if log.type in ['text', 'stdin', 'stdout_stream', 'stderr_stream']
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
                if action.metadata.debug is 'stdout'
                  process.stdout.write "#{msg}\n"
                else
                  process.stderr.write "#{msg}\n"
          if typeof action.metadata.log is 'function'
            action.metadata?.log log
          else
            return if action.metadata?.log is false
          action.operations.events.emit log.type, log
