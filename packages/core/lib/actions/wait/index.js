// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: function ({ config }) {
    return new Promise(function (resolve) {
      return setTimeout(resolve, config.time);
    });
  },
  hooks: {
    on_action: function (action) {
      const { args, handler, config } = action;
      if(!args.some((arg) => typeof arg === 'function')){
        // Fallback to default handler
        return action
      }
      // Use handler wraper
      action.config = {}
      action.metadata.argument_to_config = undefined
      action.handler = async function ({ context, tools: { log } }) {
        let attempts = 0;
        const wait = function (timeout) {
          if (!timeout) {
            return;
          }
          return new Promise(function (resolve) {
            return setTimeout(resolve, timeout);
          });
        };
        while (attempts !== config.retry) {
          attempts++;
          log({
            message: `Start attempt #${attempts}`,
            level: "DEBUG",
          });
          try {
            const result = await context.call({
              ...config,
              $handler: handler,
            });
            log({
              message: `Attempt #${attempts} succeed`,
              level: "INFO",
            });
            return {
              ...result,
              $status: attempts > 1,
            };
          } catch (err) {
            log({
              message: `Attempt #${attempts} failed with message: ${err.message}`,
              level: "WARN",
            });
            await wait(config.interval);
          }
        }
        throw utils.error("NIKITA_EXECUTE_WAIT_MAX_RETRY", [
          "the number of attempts reached the maximum number of retries,",
          `got ${config.retry}.`,
        ]);
      };
      return action;
    },
  },
  metadata: {
    argument_to_config: "time",
    definitions: definitions,
    // raw_input: true
  },
};
