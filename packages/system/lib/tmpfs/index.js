
// Dependencies
import {merge} from 'mixme';
import utils from "@nikitajs/system/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // for now only support directory type path option
    let content = {
      [config.mount]: {
        type: "d",
      },
    };
    // content[config.mount] = {};
    for (const key of ["mount", "perm", "uid", "gid", "age", "argu"]) {
      content[config.mount][key] = config[key];
    }
    // content[config.mount]["type"] = "d";
    if (config.uid != null) {
      if (!/^[0-9]+/.exec(config.uid)) {
        if (config.name == null) {
          config.name = config.uid;
        }
      }
    }
    if (config.target == null) {
      config.target =
        config.name != null
          ? `/etc/tmpfiles.d/${config.name}.conf`
          : "/etc/tmpfiles.d/default.conf";
    }
    log("DEBUG", `target set to ${config.target}`);
    if (config.merge) {
      log("DEBUG", "opening target file for merge");
      try {
        const { data } = await this.fs.base.readFile({
          target: config.target,
          encoding: "utf8",
        });
        content = merge(utils.tmpfs.parse(data), content);
        log("DEBUG", "content has been merged");
      } catch (error) {
        if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
          throw error;
        }
      }
    }
    // Serialize and write the content
    content = utils.tmpfs.stringify(content);
    const { $status } = await this.file({
      content: content,
      gid: config.gid,
      mode: config.mode,
      target: config.target,
      uid: config.uid,
    });
    if ($status) {
      log("INFO", `re-creating ${config.mount} tmpfs file`);
      await this.execute({
        command: `systemd-tmpfiles --remove ${config.target}`,
      });
      await this.execute({
        command: `systemd-tmpfiles --create ${config.target}`,
      });
    }
  },
  metadata: {
    definitions: definitions,
  },
};
