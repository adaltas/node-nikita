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
  handler: function ({ config }) {
    const serializer = {
      "nikita:action:start": function ({ action }) {
        if (!action.metadata.header) {
          return;
        }
        const walk = function (parent) {
          const precious = parent.metadata.header;
          const results = [];
          if (precious !== undefined) {
            results.push(precious);
          }
          if (parent.parent) {
            results.push(...walk(parent.parent));
          }
          return results;
        };
        const headers = walk(action);
        const header = headers.reverse().join(" : ");
        return `header,,${JSON.stringify(header)}\n`;
      },
      text: function (log) {
        return `${log.type},${log.level},${JSON.stringify(log.message)}\n`;
      },
    };
    return this.log.fs({
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
