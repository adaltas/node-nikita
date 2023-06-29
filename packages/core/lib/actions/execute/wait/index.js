
// ## Dependencies
const utils = require('../../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    let attempts = 0;
    const wait = function (timeout) {
      if (!timeout) {
        return;
      }
      return new Promise(function (resolve) {
        return setTimeout(resolve, timeout);
      });
    };
    let commands = config.command;
    while (attempts !== config.retry) {
      attempts++;
      log({
        message: `Start attempt #${attempts}`,
        level: "DEBUG",
      });
      commands = await utils.promise.array_filter(commands, async (command) => {
        const { $status: success } = await this.execute({
          command: command,
          code: config.code,
          stdin_log: config.stdin_log,
          stdout_log: config.stdout_log,
          stderr_log: config.stderr_log,
          $relax: config.code.false.length === 0,
        });
        return !success;
      });
      log({
        message: `Attempt #${attempts}, expect ${
          config.quorum
        } success to reach the quorum, got ${
          config.command.length - commands.length
        }`,
        level: "INFO",
      });
      if (commands.length <= config.command.length - config.quorum) {
        return {
          attempts: attempts,
          $status: attempts > 1,
        };
      }
      await wait(config.interval);
    }
    throw utils.error("NIKITA_EXECUTE_WAIT_MAX_RETRY", [
      "the number of attempts reached the maximum number of retries,",
      `got ${config.retry}.`,
    ]);
  },
  hooks: {
    on_action: function ({ config }) {
      // Command is required but let the schema throw an error
      if (!config.command) {
        return;
      }
      if (typeof config.command === "string") {
        config.command = [config.command];
      }
      // Always normalise quorum as an integer
      if (config.quorum && config.quorum === true) {
        return (config.quorum = Math.ceil((config.command.length + 1) / 2));
      } else if (config.quorum == null) {
        return (config.quorum = config.command.length);
      }
    },
  },
  metadata: {
    argument_to_config: "command",
    definitions: definitions,
  },
};
