// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Check if container is not already running
    const { $status: running } = await this.incus.running(config.container);
    if (running) {
      return false;
    }
    // Start the container
    return await this.execute({
      command: ["incus", "start", config.container].join(" "),
      code: [0, 42],
    });
  },
  metadata: {
    argument_to_config: "container",
    definitions: definitions,
  },
};
