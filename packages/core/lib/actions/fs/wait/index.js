// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    let status = false;
    // Validate parameters
    for (const target of config.target) {
      const { exists } = await this.fs.base.exists(target);
      if (exists) {
        continue;
      }
      await this.wait(config.interval);
      while (true) {
        const { exists } = await this.fs.base.exists(target);
        if (exists) {
          break;
        }
        status = true;
        log({
          message: "Wait for file to be created",
          level: "INFO",
        });
        await this.wait(config.interval);
      }
    }
    return status;
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
