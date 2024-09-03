// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    await this.docker.tools.execute({
      command: `volume rm ${config.name}`,
      code: [0, 1],
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
