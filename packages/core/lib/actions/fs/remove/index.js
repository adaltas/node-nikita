// Dependencies
const utils = require('../../../utils');
const definitions = require('./schema.json');

// Exports
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    // Start real work
    const { files } = await this.fs.glob(config.target);
    for (const file of files) {
      log({
        message: `Removing file ${file}`,
        level: "INFO",
      });
      try {
        const { status } = await this.execute({
          command: [
            "rm",
            "-d", // Attempt to remove directories as well as other types of files.
            config.recursive ? "-r" : void 0,
            file,
            // "rm -rf '#{file}'"
          ].join(" "),
        });
        if (status) {
          log({
            message: `File ${file} removed`,
            level: "WARN",
          });
        }
      } catch (error) {
        if (utils.string.lines(error.stderr.trim()).length === 1) {
          error.message = [
            "failed to remove the file, got message",
            JSON.stringify(error.stderr.trim()),
          ].join(" ");
        }
        throw error;
      }
    }
    return {};
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
