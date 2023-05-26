// Dependencies
const utils = require('../utils');
const {merge} = require('mixme');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    let content;
    let org_props = {};
    const parse = config.parse || utils.ini.parse;
    const stringify = config.stringify || utils.ini.stringify;
    try {
      // Original properties
      const { data } = await this.fs.base.readFile({
        target: config.target,
        encoding: config.encoding,
      });
      org_props = parse(data, config);
    } catch (error) {
      if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
        throw error;
      }
    }
    try {
      // Default properties
      if (config.source) {
        const { data } = await this.fs.base.readFile({
          $if: config.source,
          $ssh: config.local ? false : void 0,
          $sudo: config.local ? false : void 0,
          target: config.source,
          encoding: config.encoding,
        });
        content = utils.object.clean(config.content, true);
        config.content = merge(parse(data, config), config.content);
      }
    } catch (error) {
      if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
        throw error;
      }
    }
    // Merge
    if (config.merge) {
      config.content = merge(org_props, config.content);
      log({
        message: "Get content for merge",
        level: "DEBUG",
      });
    }
    if (config.clean) {
      log({
        message: "Clean content",
        level: "INFO",
      });
      utils.object.clean(config.content);
    }
    log({
      message: "Serialize content",
      level: "DEBUG",
    });
    return await this.file({
      target: config.target,
      content: stringify(config.content, config),
      backup: config.backup,
      diff: config.diff,
      eof: config.eof,
      gid: config.gid,
      uid: config.uid,
      mode: config.mode,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
