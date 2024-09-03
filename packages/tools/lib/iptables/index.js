// Dependencies
import utils from "@nikitajs/tools/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    log("WARN", "List existing rules");
    const { started } = await this.service.status({
      name: "iptables",
    });
    if (!started) {
      throw Error("Service iptables not started");
    }
    const { stdout } = await this.execute({
      $shy: true,
      command: "iptables -S",
      sudo: config.sudo,
    });
    const oldrules = utils.iptables.parse(stdout);
    const newrules = utils.iptables.normalize(config.rules);
    const command = utils.iptables.command(oldrules, newrules);
    if (!command.length) {
      return;
    }
    log("WARN", `${command.length} modified rules`);
    await this.execute({
      command: `${command.join("; ")}; service iptables save;`,
      sudo: config.sudo,
      trap: true,
    });
  },
  hooks: {
    on_action: function ({ config }) {
      if (!Array.isArray(config.rules)) {
        return (config.rules = [config.rules]);
      }
    },
  },
  metadata: {
    definitions: definitions,
  },
};
