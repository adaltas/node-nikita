// Dependencies
import path from "node:path";
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
    if (config.rootdir) {
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    return await this.file.ini(
      {
        stringify: utils.ini.stringify,
        parse: utils.ini.parse_multi_brackets,
        escape: false,
      },
      config,
    );
  },
  metadata: {
    definitions: definitions,
  },
};
