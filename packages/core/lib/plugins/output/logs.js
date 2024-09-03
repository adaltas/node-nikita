/*
# Plugin `@nikitajs/core/plugins/output/logs`

Return events emitted inside the action.
*/

import { is_object_literal } from "mixme";
import stackTrace from "stack-trace";
import path from "node:path";

export default {
  name: "@nikitajs/core/plugins/output/logs",
  require: [
    "@nikitajs/core/plugins/tools/log",
    "@nikitajs/core/plugins/output/status",
    "@nikitajs/core/plugins/metadata/raw",
  ],
  hooks: {
    "nikita:action": {
      after: "@nikitajs/core/plugins/tools/log",
      handler: function (action) {
        action.state.logs = [];
        action.tools.log = (function (fn) {
          return function (...info) {
            const log = fn.call(null, ...info);
            if (!is_object_literal(log)) {
              // Note, log is undefined if `metadata.log` is `false`
              // or any value return by `metadata.log` when a function
              return log;
            }
            // Re-compute filename
            const frame = stackTrace.get()[1];
            log.filename = frame.getFileName();
            log.file = path.basename(frame.getFileName());
            log.line = frame.getLineNumber();
            // Push log to internal state
            action.state.logs.push(log);
            return log;
          };
        })(action.tools.log);
      },
    },
    "nikita:result": {
      after: "@nikitajs/core/plugins/output/status",
      handler: function ({ action, output }, handler) {
        if (action.metadata.raw_output) {
          return handler;
        }
        return async function ({ action }) {
          try {
            output = await handler.apply(null, arguments);
            if (is_object_literal(output)) {
              output.$logs = action.state.logs;
            }
            return output;
          } catch (error) {
            error.$logs = action.state.logs;
            throw error;
          }
        };
      },
    },
  },
};
