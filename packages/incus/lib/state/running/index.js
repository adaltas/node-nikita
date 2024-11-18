// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { state } = await this.incus.state(config.name);
    return {
      running: state.status === "Running",
    };
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
    shy: true,
  },
};
