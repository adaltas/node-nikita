// Dependencies
const utils = require("../utils");
const yaml = require("js-yaml");
const { merge } = require("mixme");
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    try {
      if (config.merge) {
        const { data } = await this.fs.base.readFile({
          target: config.target,
          encoding: "utf8",
        });
        config.content = merge(yaml.load(data), config.content);
      }
    } catch (error) {
      if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
        throw error;
      }
    }
    if (config.clean) {
      log({
        message: "Cleaning content",
        level: "INFO",
      });
      utils.object.clean(config.content);
    }
    log({
      message: "Serialize content",
      level: "DEBUG",
    });
    config.content = yaml.dump(config.content, {
      noRefs: true,
      lineWidth: config.line_width,
    });
    await this.file(config);
  },
  metadata: {
    definitions: definitions,
  },
};
