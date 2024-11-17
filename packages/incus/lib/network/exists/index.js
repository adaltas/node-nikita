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
    const exists = await this.incus.network
      .list()
      .then(({ networks }) =>
        networks.some((network) => network.name === config.name),
      );
    return { exists };
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
