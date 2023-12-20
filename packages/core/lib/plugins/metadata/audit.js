/**
 * # Plugin `@nikitajs/core/plugins/metadata/debug`
 * 
 * Print the time execution of the child actions as well as various information in
 * a hierarchical tree.
 * 
 */

// Dependencies
import stream from "node:stream";
import dedent from "dedent";
import pad from "pad";
import chalk from "chalk";
import { mutate } from "mixme";
import { string } from "@nikitajs/core/utils"

// Utils
const chars = {
  horizontal: "─",
  upper_left: "┌",
  vertical: "│",
  vertical_right: "├",
};
const print_branches = (record) => {
  const branches = [];
  for (let i = 0; i < record.position.length - 1; i++) {
    if (record.position[i] === 0) {
      branches.push("   ");
    } else {
      branches.push(`${chars.vertical}  `);
    }
  }
  return branches.join('');
}
const print_leaf = (record, i) => {
  if (record.position.length === 0) return "";
  if ( record.index === 0 && i === 0 ) {
    return chars.upper_left + chars.horizontal + " "
  } else if (i === 0) {
    return chars.vertical_right + chars.horizontal + " "
  } else {
    return chars.vertical + "  ";
  }
}
const print = (ws, record) => {
  const branches = print_branches(record);
  const messages = Array.isArray(record.message) ? record.message : [record.message];
  for( let i = 0; i < messages.length; i++) {
    const prefix = i === 0 ? pad(`[${record.prefix}]`, 9) : ' '.repeat(9);
    const leaf = print_leaf(record, i);
    const message = messages[i];
    const side = ws.isTTY
      ? pad(
          ws.columns -
            prefix.length -
            branches.length -
            leaf.length -
            message.length,
          record.side || " "
        )
      : record.side && " " + record.side;
    const out_raw = [
      prefix,
      branches,
      leaf,
      message,
      side,
    ].join("");
    const out_color = record.color(out_raw);
    ws.write(`${out_color}\n`)
  }
}

// Plugin
export default {
  name: "@nikitajs/core/plugins/metadata/audit",
  require: "@nikitajs/core/plugins/tools/log",
  hooks: {
    "nikita:schema": function ({ schema }) {
      mutate(schema.definitions.metadata.properties, {
        audit: {
          oneOf: [
            {
              type: "string",
              enum: ["stdout", "stderr"],
            },
            {
              type: "boolean",
            },
            {
              instanceof: "stream.Writable",
            },
          ],
          description: dedent`
            Print the time execution of the child actions.
          `,
        },
      });
    },
    'nikita:normalize': {
      after: '@nikitajs/core/plugins/history',
      handler: function(action) {
        if (action.metadata.audit) {
          action.state.audit = {
            position: [-1],
            index: -1,
          };
        } else if (action.parent?.state?.audit) {
          // Position relative to root action
          // Before the root action complete, direct child is [0][0], second direct child is [0][1]
          action.parent.state.audit.position[action.parent.state.audit.position.length - 1]++;
          const position = action.parent.state.audit.position.concat([-1]);
          action.state.audit = {
            position: position,
            // Index of the record inside its parent
            index: -1
          };
        }
      }
    },
    "nikita:action": {
      after: ["@nikitajs/core/plugins/metadata/schema"],
      handler: function (action) {
        if (!action.metadata.audit) {
          return;
        }
        // Print child actions
        let audit = action.metadata.audit;
        const ws = audit === "stdout"
        ? process.stdout
        : audit === "stderr"
        ? process.stderr
        : audit instanceof stream.Writable
        ? audit
        : process.stderr;
        audit = action.metadata.audit = {
          colors: {
            error: (out) => ws.isTTY ? chalk.magenta(out) : out,
            info: (out) => ws.isTTY ? chalk.green(out) : out,
            stdin: (out) => ws.isTTY ? chalk.cyan(out) : out,
            stdout: (out) => ws.isTTY ? chalk.blue(out) : out,
            stderr: (out) => ws.isTTY ? chalk.magenta(out) : out,
            log: (out) => ws.isTTY ? chalk.grey(out) : out,
          },
          ws: ws,
          listeners : {
            action: function ({ action, error }) {
              const message = action.metadata.namespace?.join('.') || action.module;
              const color = error ? audit.colors.error : audit.colors.info;
              action.parent.state.audit.index++;
              print(
                audit.ws,
                {
                  color: color,
                  prefix: "ACTION",
                  message: message,
                  index: action.parent.state.audit.index,
                  position: action.parent.state.audit.position,
                  side: string.print_time(
                    action.metadata.time_end - action.metadata.time_start
                  ),
                  error: !!error,
                },
                action
              );
            },
            log: function(log, action) {
              let message =
                typeof log.message === 'string'
                ? log.message.trim()
                : typeof log.message === 'number'
                ? log.message
                : log.message?.toString != null
                ? log.message.toString().trim()
                : JSON.stringify(log.message);
              const color = (function() {
                switch (log.type) {
                  case 'stdin':
                    return audit.colors.stdin;
                  case 'stdout_stream':
                    return audit.colors.stdout;
                  case 'stderr_stream':
                    return audit.colors.stderr;
                  default:
                    return audit.colors.log;
                }
              })();
              const level = (function() {
                switch (log.type) {
                  case 'stdin':
                    return 'STDIN';
                  case 'stdout_stream':
                    return 'STDOUT';
                  case 'stderr_stream':
                    return 'STDERR';
                  default:
                    return log.level;
                }
              })();
              action.state.audit.index++;
              action.state.audit.position[action.state.audit.position.length - 1]++;
              print(audit.ws, {
                color: color,
                index: action.state.audit.index,
                prefix: level,
                message: string.lines(message),
                position: action.state.audit.position,
                side: undefined,
              });
            },
          }
        };
        action.tools.events.addListener("nikita:action:end", audit.listeners.action);
        action.tools.events.addListener('text', audit.listeners.log);
        action.tools.events.addListener('stdin', audit.listeners.log);
        action.tools.events.addListener('stdout_stream', audit.listeners.log);
        action.tools.events.addListener('stderr_stream', audit.listeners.log);
      },
    },
    "nikita:result": {
      after: "@nikitajs/core/plugins/metadata/time",
      handler: function ({ action, error }) {
        const audit = action.metadata.audit;
        if (!audit || error?.code === 'NIKITA_SCHEMA_VALIDATION_CONFIG') {
          return;
        }
        print(
          audit.ws,
          {
            color: error ? audit.colors.error : audit.colors.info,
            prefix: "ACTION",
            message: action.metadata.namespace?.join(".") || action.module || 'nikita',
            index: action.metadata.index,
            position: [],
            side: string.print_time(
              action.metadata.time_end - action.metadata.time_start
            ),
          },
          action
        );
        action.tools.events.removeListener("nikita:action:end", audit.listeners.action);
        action.tools.events.removeListener('text', audit.listeners.log);
        action.tools.events.removeListener('stdin', audit.listeners.log);
        action.tools.events.removeListener('stdout_stream', audit.listeners.log);
        action.tools.events.removeListener('stderr_stream', audit.listeners.log);
      },
    },
  },
};
