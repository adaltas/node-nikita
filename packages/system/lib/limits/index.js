// Dependencies
import regexp from "@nikitajs/core/utils/regexp";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    if (config.system && config.user) {
      throw Error(
        `Incoherent config: both system and user configuration are defined, ${JSON.stringify(
          {
            system: config.system,
            user: config.user,
          }
        )}`
      );
    }
    if (config.system) {
      config.user = "*";
    }
    if (!config.user) {
      throw Error("Missing required option 'user'");
    }
    if (config.target == null) {
      config.target =
        "/etc/security/" +
        (config.user === "*" ? "limits.conf" : `limits.d/${config.user}.conf`);
    }
    // Calculate nofile from kernel limit
    if (config.nofile != null) {
      const { stdout: kern_limit } = await this.execute({
        command: "cat /proc/sys/fs/file-max",
        // shy: true
        trim: true,
      });
      if (config.nofile === true) {
        config.nofile = Math.round(kern_limit * 0.75);
      } else if (typeof config.nofile === "number") {
        if (config.nofile >= kern_limit) {
          throw Error(
            `Invalid nofile configuration property. Please set int value lesser than kernel limit: ${kern_limit}`
          );
        }
      } else if (typeof config.nofile === "object") {
        Object.values(config.nofile).filter(v => v >= kern_limit).forEach((v) => {
          throw Error(`Invalid nofile configuration property. Please set int value lesser than kernel limit: ${kern_limit}`);
        });
      }
    }
    // Calculate nproc from kernel limit
    if (config.nproc != null) {
      const { stdout: kern_limit } = await this.execute({
        $shy: true,
        command: "cat /proc/sys/kernel/pid_max",
        trim: true,
      });
      if (config.nproc === true) {
        config.nproc = Math.round(kern_limit * 0.75);
      } else if (typeof config.nproc === "number") {
        if (config.nproc >= kern_limit) {
          throw Error(
            `Invalid nproc configuration property. Please set int value lesser than kernel limit: ${kern_limit}`
          );
        }
      } else if (typeof config.nproc === "object") {
        for (const v of config.nproc) {
          if (v >= kern_limit) {
            throw Error(
              `Invalid nproc configuration property. Please set int value lesser than kernel limit: ${kern_limit}`
            );
          }
        }
      }
    }
    // Config normalization
    const write = [];
    for (const opt of [
      "as",
      "core",
      "cpu",
      "data",
      "fsize",
      "locks",
      "maxlogins",
      "maxsyslogins",
      "memlock",
      "msgqueue",
      "nice",
      "nofile",
      "nproc",
      "priority",
      "rss",
      "sigpending",
      "stack",
      "rtprio",
    ]) {
      if (config[opt] == null) {
        continue;
      }
      if (typeof config[opt] !== "object") {
        config[opt] = {
          "-": config[opt],
        };
      }
      for (const k of Object.keys(config[opt])) {
        if (k !== "soft" && k !== "hard" && k !== "-") {
          throw Error(`Invalid option: ${JSON.stringify(config[opt])}`);
        }
        if (
          !(
            typeof config[opt][k] === "number" || config[opt][k] === "unlimited"
          )
        ) {
          throw Error(`Invalid option: ${config[opt][k]} not a number`);
        }
        write.push({
          match: RegExp(
            `^${regexp.escape(config.user)} +${regexp.escape(k)} +${opt}.+$`,
            "m"
          ),
          replace: `${config.user}    ${k}    ${opt}    ${config[opt][k]}`,
          append: true,
        });
      }
    }
    if (!write.length) {
      return false;
    }
    const {$status} = await this.file({
      target: config.target,
      write: write,
      eof: true,
      uid: config.uid,
      gid: config.gid,
    });
    return $status
  },
  metadata: {
    definitions: definitions,
  },
};
