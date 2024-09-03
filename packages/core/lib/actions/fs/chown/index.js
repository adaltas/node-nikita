// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (config.uid == null && config.gid == null) {
      throw Error("Missing one of uid or gid option");
    }
    if (typeof config.uid === "string") {
      config.uid = await this.execute(`id -u '${config.uid}'`).then(
        ({ stdout }) => parseInt(stdout.trim()),
      );
    }
    if (typeof config.gid === "string") {
      config.gid = await this.execute(`id -g '${config.gid}'`).then(
        ({ stdout }) => parseInt(stdout.trim()),
      );
    }
    // Retrieve target stats
    if (config.stats) {
      log("DEBUG", "Stat short-circuit");
    }
    config.stats ??= await this.fs
      .stat(config.target)
      .then(({ stats }) => stats);
    // Detect changes
    const changes = {
      uid: config.uid != null && config.stats.uid !== config.uid,
      gid: config.gid != null && config.stats.gid !== config.gid,
    };
    if (!changes.uid && !changes.gid) {
      log("INFO", `Matching ownerships on '${config.target}'`);
      return false;
    }
    // Apply changes
    await this.fs.base.chown({
      target: config.target,
      uid: config.uid,
      gid: config.gid,
    });
    if (changes.uid) {
      log("WARN", `change uid from ${config.stats.uid} to ${config.uid}`);
    }
    if (changes.gid) {
      log("WARN", `change gid from ${config.stats.gid} to ${config.gid}`);
    }
    return true;
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
