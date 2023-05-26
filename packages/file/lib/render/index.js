// Dependencies
const path = require('path');
const handlebars = require('handlebars');
const definitions = require('./schema.json');

// Action
module.exports = {
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
      if (config.encoding == null) {
        config.encoding = "utf8";
      }
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
