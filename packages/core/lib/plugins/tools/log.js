
/*
# Plugin `@nikitajs/core/plugins/tools/log`

The `log` plugin inject a log function into the action.handler argument.

It is possible to pass the `metadata.log` property. When `false`, logging is
disabled. When a function, the function is called with normalized logs every
time the `log` function is called with the `log`, `config` and `metadata` argument.

*/

import path from 'node:path';
import stackTrace from 'stack-trace';
import {is_object_literal, mutate} from 'mixme';
import utils from '@nikitajs/core/utils';

export default {
  name: '@nikitajs/core/plugins/tools/log',
  require: [
    '@nikitajs/core/plugins/tools/events',
    '@nikitajs/core/plugins/tools/find'
  ],
  hooks: {
    'nikita:normalize': function(action) {
      if (action.metadata.log == null && action.parent?.metadata?.log != null) {
        action.metadata.log = action.parent.metadata.log;
      }
    },
    'nikita:action': {
      after: ['@nikitajs/core/plugins/tools/events', '@nikitajs/core/plugins/metadata/debug'],
      handler: async function(action) {
        const debug = await action.tools.find(function(action) {
          return action.metadata.debug;
        });
        action.tools.log = function(...args) {
          const log = {}
          let indexMessage = -1;
          let indexLevel = -1;
          for(const i in args) {
            const arg = args[i];
            if (is_object_literal(arg)) {
              continue
            } else if (typeof arg !== 'string') {
              throw utils.error('TOOLS_LOGS_INVALID_ARGUMENT', [
                '`tools.log` accept string and object arguments,',
                `got ${JSON.stringify(arg)}.`,
              ]);
            }
            if (indexMessage === -1 && indexLevel === -1) {
              indexMessage = i;
              args[i] = {message: arg}
            } else if (indexMessage !== -1 && indexLevel === -1) {
              log.level = log.message
              log.message = arg
              args[indexMessage] = {level: args[indexMessage].message}
              args[i] = {message: arg}
              indexLevel = indexMessage;
              indexMessage = i;
            } else {
              throw utils.error('TOOLS_LOGS_INVALID_STRING_ARGUMENT', [
                '`tools.log` accept only 2 strings, a level and a message,',
                'additionnal string arguments are not supported,',
                `got ${JSON.stringify(arg)}.`
              ]);
            }
          }
          mutate(log, ...args)
          log.level ??= 'INFO';
          log.time ??= Date.now();
          log.index ??= action.metadata.index;
          log.module ??= action.metadata.module;
          log.namespace ??= action.metadata.namespace;
          log.type ??= 'text';
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
