// Dependencies
import utils from "@nikitajs/system/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function () {
    // Using `utils.os.command` to be consistant with OS conditions plugin in core
    const { stdout } = await this.execute(utils.os.command);
    const [arch, distribution, version, linux_version] = stdout.split("|");
    return {
      os: {
        arch: arch,
        distribution: distribution,
        version: version.length ? version : void 0, // eg Arch Linux
        linux_version: linux_version,
      },
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
