// Dependencies
import dedent from "dedent";
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
    //Build command
    const command_attach = [
      "incus",
      "network",
      "attach",
      esa(config.network),
      esa(config.container),
    ].join(" ");
    //Execute
    return await this.execute({
      command: dedent`
        incus config device list ${esa(config.container)} | grep ${esa(config.network)} && exit 42
        ${command_attach}
      `,
      code: [0, 42],
    });
  },
  metadata: {
    definitions: definitions,
  },
};
