// Dependencies
import { db } from "@nikitajs/db/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    await this.db.query({
      ...db.connection_config(config),
      command: `DROP USER IF EXISTS ${config.username};`,
    });
  },
  metadata: {
    argument_to_config: "username",
    global: "db",
    definitions: definitions,
  },
};
