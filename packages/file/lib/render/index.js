// Dependencies
import path from "node:path";
import handlebars from "handlebars";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // Read source
    if (config.source) {
      const { data } = await this.fs.readFile({
        $ssh: config.local ? false : undefined,
        $sudo: config.local ? false : undefined,
        target: config.source,
        encoding: config.encoding,
      });
      if (data != null) {
        config.source = undefined;
        config.content = data;
      }
    }
    log("DEBUG", `Rendering with ${config.engine}`);
    config.transform = function ({ config }) {
      const template = handlebars.compile(config.content.toString());
      return template(config.context);
    };
    await this.file(config);
  },
  hooks: {
    on_action: function ({ config }) {
      // Validate parameters
      if (!(config.source || config.content)) {
        throw Error("Required option: source or content");
      }
      // Extension
      if (!config.engine && config.source) {
        const extension = path.extname(config.source);
        switch (extension) {
          case ".hbs":
            return (config.engine = "handlebars");
          default:
            throw Error(
              `Invalid Option: extension '${extension}' is not supported`,
            );
        }
      }
    },
  },
  metadata: {
    definitions: definitions,
    templated: false,
  },
};
