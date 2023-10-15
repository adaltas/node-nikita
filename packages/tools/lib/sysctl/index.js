
// Dependencies
const definitions = require("./schema.json");
const utils = require('../utils');

// Action
module.exports = {
  handler: async function({
    config,
    tools: {log}
  }) {
    // Read current properties
    const current = {};
    let $status = false;
    log({
      message: `Read target: ${config.target}`,
      level: 'DEBUG'
    });
    try {
      const {data} = await this.fs.base.readFile({
        target: config.target,
        encoding: 'ascii'
      });
      for (const line of utils.string.lines(data)) {
        // Preserve comments
        if (/^#/.test(line)) {
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
        let [key, value] = line.split('=');
        // Trim
        key = key.trim();
        value = value.trim();
        // 231015: This was generating an error in merge test
        // not sure what it is meant to achieve at the first place
        // Skip property
        // if (config.properties[key] == null) {
        //   log(`Removing Property: ${key}, was ${value}`, {
        //     level: 'INFO'
        //   });
        //   $status = true;
        //   continue;
        // }
        // Set property
        current[key] = value;
      }
    } catch (error) {
      if (error.code !== 'NIKITA_FS_CRS_TARGET_ENOENT') {
        throw error;
      }
    }
    // Merge user properties
    const final = {};
    if (config.merge) {
      for (const key in current) {
        final[key] = current[key];
      }
    }
    $status = false;
    for (const key in config.properties) {
      let value = config.properties[key];
      if (value == null) {
        continue;
      }
      if (typeof value === 'number') {
        value = `${value}`;
      }
      if (current[key] === value) {
        continue;
      }
      log(`Update Property: key \"${key}\" from \"${final[key]}\" to \"${value}\"`, {
        level: 'INFO'
      });
      final[key] = value;
      $status = true;
    }
    if ($status) {
      await this.file({
        target: config.target,
        backup: config.backup,
        content: Object.keys(final)
          .map((key) => (final[key] != null ? `${key} = ${final[key]}` : `${key}`))
          .join("\n"),
      });
    }
    if (config.load && $status) {
      await this.execute(`sysctl -p ${config.target}`);
    }
  },
  metadata: {
    definitions: definitions
  }
};
