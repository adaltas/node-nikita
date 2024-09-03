// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    let status = false;
    // Validate parameters
    for (const target of config.target) {
      const { exists } = await this.fs.exists(target);
      if (exists) {
        continue;
      }
      await this.wait(config.interval);
      while (true) {
        const { exists } = await this.fs.exists(target);
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
