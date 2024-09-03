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
    return {
      exists: await this.db
        .query({
          ...db.connection_config(config),
          command: `SELECT 1 FROM pg_namespace WHERE nspname = '${config.schema}';`,
          grep: "1",
        })
        .then(({ $status: exists }) => exists),
    };
  },
  metadata: {
    global: "db",
    definitions: definitions,
  },
};
