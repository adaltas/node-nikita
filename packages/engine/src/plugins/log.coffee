
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
          log = message: log if typeof log is 'string'
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
          if typeof action.metadata.log is 'function'
            action.metadata?.log log
          else
            return if action.metadata?.log is false
          action.operations.events.emit log.type, log, action
