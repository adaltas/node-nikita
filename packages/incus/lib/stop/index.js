// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Check if container is running
    const { running } = await this.incus.state.running(config.container);
    if (!running) {
      return false;
    }
    // Stop the container
    await this.execute({
      command: `incus stop ${config.container}`,
      code: [0, 42],
    });
    if (config.wait) {
      await this.execute.wait({
        $shy: true,
        command: `incus info ${config.container} | grep 'Status: STOPPED'`,
        retry: config.wait_retry,
        interval: config.wait_interval,
      });
    }
    return true;
  },
  metadata: {
    argument_to_config: "container",
    definitions: definitions,
  },
};
