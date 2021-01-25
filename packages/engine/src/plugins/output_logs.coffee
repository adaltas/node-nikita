

###
Return events emitted inside the action

###

{is_object_literal} = require 'mixme'
stackTrace = require 'stack-trace'
path = require 'path'

module.exports =
  module: '@nikitajs/engine/src/plugins/output_logs'
  require: [
    '@nikitajs/engine/src/plugins/tools_log'
    '@nikitajs/engine/src/metadata/status'
    '@nikitajs/engine/src/metadata/raw'
  ]
  hooks:
    'nikita:session:action':
      after: '@nikitajs/engine/src/plugins/tools_log'
      handler: (action) ->
        action.state.logs = []
        action.tools.log = ( (fn) ->
          (info) ->
            log = fn.call null, info
            # Note, log is undefined if `metadata.log` is `false`
            # or any value return by `metadata.log` when a function
            return log unless is_object_literal log
            # Re-compute filename
            frame = stackTrace.get()[1]
            log.filename = frame.getFileName()
            log.file = path.basename(frame.getFileName())
            log.line = frame.getLineNumber()
            # Push log to internal state
            action.state.logs.push log
            log
        )(action.tools.log)
    'nikita:session:result':
      after: '@nikitajs/engine/src/metadata/status'
      handler: ({action, output}, handler) ->
        return handler if action.metadata.raw_output
        ({action}) ->
          output = await handler.apply null, arguments
          output.logs = action.state.logs if is_object_literal output
          output
