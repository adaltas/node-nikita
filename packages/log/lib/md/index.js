// Dependencies
import { merge } from "mixme";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const state = {};
    const serializer = {
      diff: function (log) {
        if (log.message) {
          return `\n\`\`\`diff\n${log.message}\`\`\`\n`;
        }
      },
      "nikita:action:start": function ({ action }) {
        const content = [];
        // Header message
        if (action.metadata.header) {
          const walk = function (parent) {
            const precious = parent.metadata.header;
            const results = [];
            if (precious !== void 0) {
              results.push(precious);
            }
            if (parent.parent) {
              results.push(...walk(parent.parent));
            }
            return results;
          };
          const headers = walk(action);
          const header = headers.reverse().join(config.divider);
          content.push("\n");
          content.push("#".repeat(headers.length));
          content.push(` ${header}\n`);
        }
        // Entering message
        let act = action.parent;
        let bastard = false;
        while (act) {
          bastard = act.metadata.bastard;
          if (bastard === true) {
            break;
          }
          act = act.parent;
        }
        if (
          config.enter &&
          action.metadata.module &&
          action.metadata.log !== false &&
          bastard !== true
        ) {
          content.push(
            [
              "\n",
              "Entering",
              " ",
              `${action.metadata.module}`,
              " ",
              "(",
              `${action.metadata.position
                .map(function (index) {
                  return index + 1;
                })
                .join(".")}`,
              ")",
              "\n",
            ].join(""),
          );
        }
        return content.join("");
      },
      stdin: function (log) {
        const out = [];
        if (log.message.indexOf("\n") === -1) {
          out.push(`\nRunning Command: \`${log.message}\`\n`);
        } else {
          out.push(`\n\`\`\`stdin\n${log.message}\n\`\`\`\n`);
        }
        return out.join("");
      },
      stdout_stream: function (log) {
        if (log.message === null) {
          state.stdout_count = 0;
        } else if (state.stdout_count === void 0) {
          state.stdout_count = 1;
        } else {
          state.stdout_count++;
        }
        const out = [];
        if (state.stdout_count === 1) {
          out.push("\n```stdout\n");
        }
        if (state.stdout_count > 0) {
          out.push(log.message);
        }
        if (state.stdout_count === 0) {
          out.push("\n```\n");
        }
        return out.join("");
      },
      text: function (log) {
        const out = [];
        out.push(`\n${log.message}`);
        if (log.module && log.module !== "@nikitajs/core/actions/call") {
          out.push(` (${log.depth}.${log.level}, written by ${log.module})`);
        }
        out.push("\n");
        return out.join("");
      },
    };
    await this.log.fs({
      archive: config.archive,
      basedir: config.basedir,
      filename: config.filename,
      serializer: merge(serializer, config.serializer),
    });
  },
  metadata: {
    definitions: definitions,
  },
};
