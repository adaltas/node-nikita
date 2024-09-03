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
    if (config.target == null) {
      config.target = `/etc/wireguard/${config.interface}.conf`;
    }
    if (config.rootdir) {
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    await this.file.ini({
      parse: utils.ini.parse_multi_brackets,
      stringify: utils.ini.stringify_multi_brackets,
      indent: "",
      ...utils.object.filter(config, ["interface", "rootdir"]),
    });
  },
  metadata: {
    definitions: definitions,
  },
};
