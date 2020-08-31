
{EventEmitter} = require 'events'
stackTrace = require 'stack-trace'
path = require 'path'

###
The `log` plugin inject a log fonction into the action.handler argument.

It is possible to pass the `metadata.log` property. When `false`, logging is
disabled. When a function, the function is called with normalized logs every
time the `log` function is called with the `log`, `config` and `metadata` argument.

###

module.exports = ->
  module: '@nikitajs/engine/src/plugins/log'
  require: '@nikitajs/engine/src/plugins/events'
  hooks:
    'nikita:session:normalize': (action) ->
      # Move property from action to metadata
      if action.hasOwnProperty 'log'
        action.metadata.log = action.log
        delete action.log
      if not action.metadata.log? and action.parent?.metadata?.log?
        action.metadata.log = action.parent.metadata.log
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
            action.metadata?.log
              log: log
              config: action.config
              metadata: action.metadata
          else
            return if action.metadata?.log is false
          action.operations.events.emit log.type, log, action
