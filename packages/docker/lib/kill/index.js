// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { $status } = await this.docker.tools.execute({
      command: `ps | egrep ' ${config.container}$' | grep 'Up'`,
      code: [0, 1],
    });
    await this.docker.tools.execute({
      $if: $status,
      command: [
        "kill",
        config.signal != null && `-s ${config.signal}`,
        `${config.container}`,
      ]
        .filter(Boolean)
        .join(" "),
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
