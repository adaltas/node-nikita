// Dependencies
import utils from "@nikitajs/core/utils";
import { escapeshellarg as esa } from "@nikitajs/utils/string";
import execute from "@nikitajs/core/actions/execute";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

const properties = Object.keys(
  execute.metadata.definitions.config.properties,
).filter((prop) => !["command", "trap", "env"].includes(prop));

// Action
export default {
  handler: async function ({ config }) {
    const opt = [
      // Incus `--user` only support user ID (integer)
      config.user && `--user ${config.user}`,
      config.cwd && `--cwd ${esa(config.cwd)}`,
      ...Object.keys(config.env).map(
        (k) => `--env ${esa(k)}=${esa(config.env[k])}`,
      ),
    ]
      .filter(Boolean)
      .join(" ");
    return await this.execute(
      // `trap` and `env` apply to `incus exec` and not to `execute`
      // { ...config, env: undefined, trap: undefined },
      {
        ...utils.object.copy(config, properties),
        command: [
          `cat <<'NIKITAINCUSEXEC' | incus exec ${opt} ${esa(config.name)} -- ${esa(config.shell)}`,
          config.trap && "set -e",
          config.command,
          "NIKITAINCUSEXEC",
        ]
          .filter(Boolean)
          .join("\n"),
      },
    );
  },
  metadata: {
    definitions: definitions,
  },
};
