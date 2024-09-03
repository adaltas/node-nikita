// Dependencies
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const stats =
      config.stats ??
      (await this.fs.stat(config.target).then(({ stats }) => stats));
    // Detect changes
    if (utils.mode.compare(stats.mode, config.mode)) {
      log(
        "INFO",
        `Identical permissions "${config.mode.toString(8)}" on "${
          config.target
        }"`,
      );
      return false;
    }
    // Apply changes
    await this.fs.base.chmod({
      target: config.target,
      mode: config.mode,
    });
    log(
      "WARN",
      [
        `Permissions changed`,
        `from "${stats.mode.toString(8)}"`,
        `to "${config.mode.toString(8)}"`,
        `on "${config.target}"`,
      ].join(" "),
    );
    return true;
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
