// Dependencies
import utils from "@nikitajs/file/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    return await this.file.ini(
      {
        stringify: utils.ini.stringify_single_key,
      },
      config,
    );
  },
  metadata: {
    definitions: definitions,
  },
};
