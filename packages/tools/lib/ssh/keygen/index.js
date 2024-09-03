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
  handler: async function ({ config, tools: { path } }) {
    await this.fs.mkdir({
      target: `${path.dirname(config.target)}`,
    });
    await this.execute({
      $unless_exists: `${config.target}`,
      command: [
        "ssh-keygen",
        "-q", // Silence
        `-t ${config.type}`,
        `-b ${config.bits}`,
        config.key_format && `-m ${esa(config.key_format)}`,
        config.comment && `-C ${esa(config.comment)}`,
        `-N ${esa(config.passphrase)}`,
        `-f ${esa(config.target)}`,
      ]
        .filter(Boolean)
        .join(" "),
    });
  },
  metadata: {
    definitions: definitions,
  },
};
