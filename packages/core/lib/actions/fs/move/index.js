// Dependencies
const definitions = require('./schema.json');

// Exports
module.exports = {
  handler: async function ({ config, tools: { log, path } }) {
    const { exists } = await this.fs.base.exists(config.target);
    if (!exists) {
      log({
        message: `Rename ${config.source} to ${config.target}`,
        level: "WARN",
      });
      await this.fs.base.rename({
        source: config.source,
        target: config.target,
      });
      return true;
    }
    if (config.force) {
      log({
        message: `Remove ${config.target}`,
        level: "WARN",
      });
      await this.fs.remove({
        target: config.target,
      });
      log({
        message: `Rename ${config.source} to ${config.target}`,
        level: "WARN",
      });
      await this.fs.base.rename({
        source: config.source,
        target: config.target,
      });
      return true;
    }
    if (!config.target_md5) {
      log({
        message: "Get target md5",
        level: "DEBUG",
      });
      const { hash } = await this.fs.hash(config.target);
      log({
        message: 'Destination md5 is "hash"',
        level: "INFO",
      });
      config.target_md5 = hash;
    }
    if (!config.source_md5) {
      log({
        message: "Get source md5",
        level: "DEBUG",
      });
      const { hash } = await this.fs.hash(config.source);
      log({
        message: 'Source md5 is "hash"',
        level: "INFO",
      });
      config.source_md5 = hash;
    }
    if (config.source_md5 === config.target_md5) {
      log({
        message: `Remove ${config.source}`,
        level: "WARN",
      });
      await this.fs.remove({
        target: config.source,
      });
      return false;
    }
    log({
      message: `Remove ${config.target}`,
      level: "WARN",
    });
    await this.fs.remove({
      target: config.target,
    });
    log({
      message: `Rename ${config.source} to ${config.target}`,
      level: "WARN",
    });
    await this.fs.base.rename({
      source: config.source,
      target: config.target,
    });
    return {};
  },
  metadata: {
    definitions: definitions,
  },
};
