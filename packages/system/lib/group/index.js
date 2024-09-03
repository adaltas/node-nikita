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
  handler: async function ({ config, tools: { log } }) {
    // throw Error 'Invalid gid option' if config.gid? and isNaN config.gid
    const { groups } = await this.system.group.read();
    const info = groups[config.name];
    log(
      "DEBUG",
      info ?
        `Got group information for ${JSON.stringify(config.name)}`
      : `Group ${JSON.stringify(config.name)} not present`,
    );
    if (!info) {
      // Create group
      const { $status } = await this.execute({
        command: [
          "groupadd",
          config.system && "-r",
          config.gid != null && `-g ${esa("" + config.gid)}`,
          esa(config.name),
        ]
          .filter(Boolean)
          .join(" "),
        code: [0, 9],
      });
      if (!$status) {
        // Modify group
        log(
          "WARN",
          "Group defined elsewhere than '/etc/group', exit code is 9",
        );
      }
    } else {
      const changes = ["gid"].filter(
        (k) => config[k] != null && `${info[k]}` !== `${config[k]}`,
      );
      if (changes.length) {
        await this.execute({
          command: [
            "groupmod",
            config.gid && ` -g ${esa(config.gid)}`,
            esa(config.name),
          ].join(" "),
        });
        log("WARN", "Group information modified");
      } else {
        log("Group information unchanged");
      }
    }
  },
  hooks: {
    on_action: function ({ config }) {
      if (typeof config.gid === "string") {
        config.gid = parseInt(config.gid, 10);
      }
    },
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
