// Dependencies
import dedent from "dedent";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { exists } = await this.incus.config.device.exists({
      name: config.container,
      device: config.name,
    });
    if (!exists) return false;
    // console.log(${["incus", "network", "detach", config.name, config.container].join(" ")})
    // process.exit()
    const { $status } = await this.execute({
      command: dedent`
        ${["incus", "network", "detach", config.name, config.container].join(" ")}
      `,
      code: [0, 42],
    });
    return $status;
  },
  metadata: {
    definitions: definitions,
  },
};
