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
    const { $status } = await this.execute({
      command: dedent`
        incus config device list ${config.container} | grep ${config.network} || exit 42
        ${["incus", "network", "detach", config.network, config.container].join(" ")}
      `,
      code: [0, 42],
    });
    return $status;
  },
  metadata: {
    definitions: definitions,
  },
};
