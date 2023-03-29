
/*
# Plugin `@nikitajs/core/lib/plugins/tools/log`

The `log` plugin inject a log function into the action.handler argument.

It is possible to pass the `metadata.log` property. When `false`, logging is
disabled. When a function, the function is called with normalized logs every
time the `log` function is called with the `log`, `config` and `metadata` argument.

*/

const {EventEmitter} = require('events');
const stackTrace = require('stack-trace');
const path = require('path');
const {merge} = require('mixme');

module.exports = {
  name: '@nikitajs/core/lib/plugins/tools/log',
  require: [
    '@nikitajs/core/lib/plugins/tools/events',
    '@nikitajs/core/lib/plugins/tools/find'
  ],
  hooks: {
    'nikita:normalize': function(action) {
      if (action.metadata.log == null && action.parent?.metadata?.log != null) {
        action.metadata.log = action.parent.metadata.log;
      }
    },
    'nikita:action': {
      after: ['@nikitajs/core/lib/plugins/tools/events', '@nikitajs/core/lib/plugins/metadata/debug'],
      handler: async function(action) {
        const debug = await action.tools.find(function(action) {
          return action.metadata.debug;
        });
        return action.tools.log = function(log) {
          var ref, ref1;
          log = merge(log);
          if (typeof log === 'string') {
            log = {
              message: log
            };
          }
          if (log.level == null) {
            log.level = 'INFO';
          }
          if (log.time == null) {
            log.time = Date.now();
          }
          if (log.index == null) {
            log.index = action.metadata.index;
          }
          if (log.module == null) {
            log.module = action.metadata.module;
          }
          if (log.namespace == null) {
            log.namespace = action.metadata.namespace;
          }
          if (log.type == null) {
            log.type = 'text';
          }
          log.depth = action.metadata.depth;
          log.index = action.metadata.index;
          log.position = action.metadata.position;
          const frame = stackTrace.get()[1];
          log.filename = frame.getFileName();
          log.file = path.basename(frame.getFileName());
          log.line = frame.getLineNumber();
          if (typeof action.metadata.log === 'function') {
            if (action.metadata != null) {
              action.metadata.log({
                log: log,
                config: action.config,
                metadata: action.metadata
              });
            }
          } else {
            if (!debug && action.metadata?.log  === false) {
              return;
            }
          }
          action.tools.events.emit(log.type, log, action);
          return log;
        };
      }
    }
  }
};
