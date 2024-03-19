// Dependencies
import path from 'node:path'
import handlebars from 'handlebars';
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // Read source
    if (config.source) {
      const { data } = await this.fs.base.readFile({
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
    log({
      message: `Rendering with ${config.engine}`,
      level: "DEBUG",
    });
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
              `Invalid Option: extension '${extension}' is not supported`
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
