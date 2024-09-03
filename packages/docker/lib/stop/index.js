// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // rm is false by default only if config.service is true
    const { $status } = await this.docker.tools.status(config, {
      $shy: true,
    });
    if ($status) {
      log("INFO", `Stopping container ${config.container}`);
    } else {
      log("INFO", `Container already stopped ${config.container} (Skipping)`);
    }
    await this.docker.tools.execute({
      $if: $status,
      command: [
        "stop",
        config.timeout != null ? `-t ${config.timeout}` : void 0,
        `${config.container}`,
      ].join(" "),
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
