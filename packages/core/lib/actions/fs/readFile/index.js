// Dependencies
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Normalize options
    const buffers = [];
    await this.fs.createReadStream({
      target: config.target,
      on_readable: function (rs) {
        const results = [];
        let buffer;
        while ((buffer = rs.read())) {
          results.push(buffers.push(buffer));
        }
        return results;
      },
    });
    let data = Buffer.concat(buffers);
    if (config.encoding) {
      data = data.toString(config.encoding);
    }
    if (config.trim && typeof data === "string") {
      data = data.trim();
    }
    if (config.format) {
      data = await utils.string.format(data, config.format);
    }
    return {
      data: data,
    };
  },
  metadata: {
    argument_to_config: "target",
    log: false,
    raw_output: true,
    definitions: definitions,
  },
};
