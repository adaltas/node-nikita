// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { state } = await this.incus.state(config.container);
    return {
      running: state.status === "Running",
    };
  },
  metadata: {
    argument_to_config: "container",
    definitions: definitions,
    shy: true,
  },
};
