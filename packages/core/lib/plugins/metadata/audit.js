/**
 * # Plugin `@nikitajs/core/plugins/metadata/debug`
 * 
 * Print the time execution of the child actions.
 * 
 */

// Dependencies
import stream from "node:stream";
import dedent from "dedent";
import pad from "pad";
import { mutate } from "mixme";
import { string } from "@nikitajs/core/utils"

// Utils
const chars = {
  horizontal: "─",
  upper_left: "┌",
  vertical: "│",
  vertical_right: "├",
};
const branches = (record) => {
  const depth = record.depth - record.rootDepth;
  const position = record.position.slice(record.rootDepth+1)
  const branches = [];
  for (let i = 0; i < depth - (record.type ? 0 : 1); i++) {
    if (position[i] === 0) {
      branches.push("   ");
    } else {
      branches.push(`${chars.vertical}  `);
    }
  }
  return branches.join('');
}
const leaf = (record) => {
  return `${record.index === 0 ? chars.upper_left : chars.vertical_right}${chars.horizontal} `;
}
const bullet = (record) => {
  return `- `;
}
const print_log = (ws, record) => {
  const depth = record.depth - record.rootDepth;
  console.log(record, '>', branches(record))
  let msg =
    typeof record.message === 'string'
    ? record.message.trim()
    : typeof record.message === 'number'
    ? record.message
    : record.message?.toString != null
    ? record.message.toString().trim()
    : JSON.stringify(record.message);
  const elements = [
    pad(`[${record.level}]`, 8),
    depth > 0 && branches(record),
    depth > 0 && leaf(record),
    // bullet(record),
    ' ',
    msg,
  ].filter(Boolean)
  if(ws.isTTY){
    let out = elements.join('')
    out = (function() {
      switch (record.type) {
        case 'stdin':
          return `\x1b[33m${out}\x1b[39m`;
        case 'stdout_stream':
          return `\x1b[36m${out}\x1b[39m`;
        case 'stderr_stream':
          return `\x1b[35m${out}\x1b[39m`;
        default:
          return `\x1b[32m${out}\x1b[39m`;
      }
    })();
    ws.write(`${out}\n`)
  }else{
    let out = elements.join('')
    ws.write(`${out}\n`);
  }
}
const print = (ws, record) => {
  const depth = record.depth - record.rootDepth;
  const elements = [
    pad("[AUDIT]", 8),
    depth > 0 && branches(record),
    depth > 0 && leaf(record),
    record.name,
  ].filter(Boolean);
  if(ws.isTTY){
    let out = elements.join('');
    out += pad(ws.columns - msg.length, record.time);
    out = `\x1b[33m${msg}\x1b[39m`;
    ws.write(`${out}\n`)
  }else{
    elements.push(' ', record.time);
    let out = elements.join('');
    ws.write(`${out}\n`);
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
    "nikita:action": {
      after: ["@nikitajs/core/plugins/metadata/schema"],
      handler: function (action) {
        if (!action.metadata.audit) {
          return;
        }
        // Print child actions
        let audit = action.metadata.audit;
        const rootDepth = action.metadata.depth
        audit = action.metadata.audit = {
          ws:
            audit === "stdout"
              ? process.stdout
              : audit === "stderr"
              ? process.stderr
              : audit instanceof stream.Writable
              ? audit
              : process.stderr,
          listener_end: function ({ action }) {
            print(audit.ws, {
              name: action.metadata.namespace?.join('.') || action.module,
              depth: action.metadata.depth,
              index: action.metadata.index,
              position: action.metadata.position,
              rootDepth: rootDepth,
              time: string.print_time(action.metadata.time_end - action.metadata.time_start),
            }, action);
          },
          listener: function(log) {
            print_log(audit.ws, {
              name: log.namespace?.join('.') || log.module,
              depth: log.depth,
              index: log.index,
              level: log.level,
              message: log.message,
              position: log.position,
              rootDepth: rootDepth,
              time: undefined,
            });
          },
        };
        action.tools.events.addListener("nikita:action:end", audit.listener_end);
        action.tools.events.addListener('text', audit.listener);
        action.tools.events.addListener('stdin', audit.listener);
        action.tools.events.addListener('stdout_stream', audit.listener);
        action.tools.events.addListener('stderr_stream', audit.listener);
      },
    },
    "nikita:result": {
      after: "@nikitajs/core/plugins/metadata/time",
      handler: function ({ action }) {
        const audit = action.metadata.audit;
        if (!(audit && audit.listener)) {
          return;
        }
        print(audit.ws, {
          name: action.metadata.namespace?.join('.') || action.module,
          index: action.metadata.index,
          depth: action.metadata.depth,
          position: [],
          rootDepth: action.metadata.depth,
          time: string.print_time(action.metadata.time_end - action.metadata.time_start),
        }, action);
        action.tools.events.removeListener("nikita:action:end", audit.listener_end);
      },
    },
  },
};
