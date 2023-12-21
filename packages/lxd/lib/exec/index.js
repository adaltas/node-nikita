// Dependencies
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const opt = [
      // LXD `--user` only support user ID (integer)
      config.user && `--user ${config.user}`,
      config.cwd && `--cwd ${esa(config.cwd)}`,
      ...Object.keys(config.env).map(
        (k) => `--env ${esa(k)}=${esa(config.env[k])}`
      ),
    ].filter(Boolean).join(" ");
    return await this.execute(
      // `trap` and `env` apply to `lxc exec` and not to `execute`
      { ...config, env: undefined, trap: undefined },
      {
        command: [
          `cat <<'NIKITALXDEXEC' | lxc exec ${opt} ${esa(config.container)} -- ${esa(config.shell)}`,
          config.trap && "set -e",
          config.command,
          "NIKITALXDEXEC",
        ].filter(Boolean).join("\n"),
      }
    );
  },
  metadata: {
    definitions: definitions
  }
};
