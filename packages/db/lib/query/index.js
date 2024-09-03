// Dependencies
import utils from "@nikitajs/db/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { $status, stdout } = await this.execute({
      code: config.code,
      command: utils.db.command(config),
      trim: config.trim,
    });
    return {
      $status:
        config.grep ?
          utils.regexp.is(config.grep) ?
            stdout.split("\n").some((line) => config.grep.test(line))
          : stdout.split("\n").some((line) => line === config.grep)
        : $status,
      stdout: stdout,
    };
  },
  hooks: {
    on_action: ({ config }) => {
      config.engine = config.engine?.toLowerCase();
    },
  },
  metadata: {
    global: "db",
    definitions: definitions,
  },
};
