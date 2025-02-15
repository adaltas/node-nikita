// Dependencies
import quote from "regexp-quote";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Actions
export default {
  handler: async function ({ config }) {
    const { data } = await this.fs.readFile({
      target: config.target,
      encoding: config.encoding,
    });
    const properties = {};
    // Parse
    const lines = data.split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
    for (const line of lines) {
      if (/^\s*$/.test(line)) {
        // Empty line
        continue;
      }
      if (/^#/.test(line)) {
        // Comment
        if (config.comment) {
          properties[line] = null;
        }
        continue;
      }
      let [, k, v] = RegExp(`^(.*?)${quote(config.separator)}(.*)$`).exec(line);
      if (config.trim) {
        k = k.trim();
      }
      if (config.trim) {
        v = v.trim();
      }
      properties[k] = v;
    }
    return {
      properties: properties,
    };
  },
  metadata: {
    definitions: definitions,
  },
};
