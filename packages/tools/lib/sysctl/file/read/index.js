
// Dependencies
import utils from "@nikitajs/tools/utils";
import definitions from "./schema.json" with { type: "json" };


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
