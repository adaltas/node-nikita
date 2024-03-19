
/*
# Plugin `@nikitajs/core/plugins/metadata/debug`

Print log information to the console.

Only the logs which type match "text", "stdin", "stdout_stream", "stderr_stream" are handled.

TODO: detect/force isTTY
*/

// Dependencies
import stream from 'node:stream';
import dedent from 'dedent';
import {mutate} from 'mixme';

// Plugin
export default {
  name: '@nikitajs/core/plugins/metadata/debug',
  require: '@nikitajs/core/plugins/tools/log',
  hooks: {
    'nikita:schema': function({schema}) {
      mutate(schema.definitions.metadata.properties, {
        debug: {
          oneOf: [
            {
              type: 'string',
              enum: ['stdout', 'stderr']
            },
            {
              type: 'boolean'
            },
            {
              instanceof: 'stream.Writable'
            }
          ],
          description: dedent`
            Print detailed information of an action and its children. It
            provides a quick and convenient solution to understand the various
            actions called, what they do, and in which order.
          `
        }
      });
    },
    'nikita:action': {
      after: ['@nikitajs/core/plugins/metadata/schema'],
      handler: function(action) {
        if (!action.metadata.debug) {
          return;
        }
        let debug = action.metadata.debug;
        debug = action.metadata.debug = {
          ws:
            debug === 'stdout'
            ? process.stdout
            : debug === 'stderr'
            ? process.stderr
            : debug instanceof stream.Writable
            ? debug
            : process.stderr,
          listener: function(log) {
            if(['stdout_stream', 'stderr_stream'].includes(log.type) && log.message == null){
              return
            }
            let msg =
              typeof log.message === 'string'
              ? log.message.trim()
              : typeof log.message === 'number'
              ? log.message
              : log.message?.toString != null
              ? log.message.toString().trim()
              : JSON.stringify(log.message);
            const type = log.type.split('_')[0];
            const position = log.position.map((i) => i + 1).join('.');
            const name = log.namespace?.join('.') || log.module;
            msg = ['[', type, ' ', position + ' ' + log.level, name ? ' ' + name : void 0, '] ', msg].join('');
            msg = (function() {
              switch (log.type) {
                case 'stdin':
                  return `\x1b[33m${msg}\x1b[39m`;
                case 'stdout_stream':
                  return `\x1b[36m${msg}\x1b[39m`;
                case 'stderr_stream':
                  return `\x1b[35m${msg}\x1b[39m`;
                default:
                  return `\x1b[32m${msg}\x1b[39m`;
              }
            })();
            debug.ws.write(`${msg}\n`);
          }
        };
        action.tools.events.addListener('text', debug.listener);
        action.tools.events.addListener('stdin', debug.listener);
        action.tools.events.addListener('stdout_stream', debug.listener);
        action.tools.events.addListener('stderr_stream', debug.listener);
      }
    },
    'nikita:result': {
      handler: function({action}) {
        const debug = action.metadata.debug;
        if (!(debug && debug.listener)) {
          return;
        }
        action.tools.events.removeListener('text', debug.listener);
        action.tools.events.removeListener('stdin', debug.listener);
        action.tools.events.removeListener('stdout_stream', debug.listener);
        action.tools.events.removeListener('stderr_stream', debug.listener);
      }
    }
  }
};
