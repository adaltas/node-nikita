// Dependencies
import { escapeshellarg as esa } from "@nikitajs/utils/string";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const command = ["logout", config.registry && esa(config.registry)]
      .filter(Boolean)
      .map(" ");
    await this.docker.tools.execute({
      command: command,
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
