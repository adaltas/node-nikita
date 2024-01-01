// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
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
          log("DEBUG", `Start attempt #${attempts}`);
          try {
            const result = await context.call({
              ...config,
              $handler: handler,
            });
            log("INFO", `Attempt #${attempts} succeed`);
            return {
              ...result,
              $status: attempts > 1,
            };
          } catch (err) {
            log("WARN" `Attempt #${attempts} failed with message: ${err.message}`);
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
