// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (!(config.uid != null || config.gid != null)) {
      throw Error("Missing one of uid or gid option");
    }
    let uid;
    if (config.uid != null) {
      uid =
        typeof config.uid === "number"
          ? config.uid
          : parseInt((await this.execute(`id -u '${config.uid}'`)).stdout.trim());
    }
    let gid;
    if (config.gid != null) {
      gid =
        typeof config.gid === "number"
          ? config.gid
          : parseInt((await this.execute(`id -g '${config.gid}'`)).stdout.trim());
    }
    // Retrieve target stats
    let stats;
    if (config.stats) {
      log({
        message: "Stat short-circuit",
        level: "DEBUG",
      });
      stats = config.stats;
    } else {
      ({ stats } = await this.fs.stat(config.target));
    }
    // Detect changes
    const changes = {
      uid: uid != null && stats.uid !== uid,
      gid: gid != null && stats.gid !== gid,
    };
    if (!changes.uid && !changes.gid) {
      log({
        message: `Matching ownerships on '${config.target}'`,
        level: "INFO",
      });
      return false;
    }
    // Apply changes
    await this.fs.base.chown({
      target: config.target,
      uid: uid,
      gid: gid,
    });
    if (changes.uid) {
      log({
        message: `change uid from ${stats.uid} to ${uid}`,
        level: "WARN",
      });
    }
    if (changes.gid) {
      log({
        message: `change gid from ${stats.gid} to ${gid}`,
        level: "WARN",
      });
    }
    return true;
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
