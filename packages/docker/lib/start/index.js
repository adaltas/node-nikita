// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const { $status } = await this.docker.tools.status({
      container: config.container,
      $shy: true,
    });
    if ($status) {
      log(`Container already started ${config.container} (Skipping)`);
    } else {
      log(`Starting container ${config.container}`);
    }
    await this.docker.tools.execute({
      $unless: $status,
      command: ["start", config.attach && "-a", `${config.container}`]
        .filter(Boolean)
        .join(" "),
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
