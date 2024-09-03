// Dependencies
import utils from "@nikitajs/tools/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

export default {
  handler: async function ({ config, tools: { log } }) {
    log("DEBUG", `Read sysctl file: ${config.target}`);
    const data = await this.fs
      .readFile({
        target: config.target,
        encoding: "ascii",
      })
      .then(({ data }) => {
        const current = {};
        for (const line of utils.string.lines(data)) {
          // Preserve comments
          if (line.startsWith("#")) {
            if (config.comment) {
              current[line] = null;
            }
            continue;
          }
          // Empty line
          if (/^\s*$/.test(line)) {
            current[line] = null;
            continue;
          }
          let [key, value] = line.split("=");
          // Trim
          key = key.trim();
          value = value.trim();
          // Set property
          current[key] = value;
        }
        return current;
      });
    return { data: data };
  },
  metadata: {
    definitions: definitions,
  },
};
