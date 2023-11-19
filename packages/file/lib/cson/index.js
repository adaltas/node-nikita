// ## Dependencies
import {merge} from 'mixme';
import cson from 'cson';
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (config.merge) {
      log({
        message: "Get Target Content",
        level: "DEBUG",
      });
      try {
        const { data } = await this.fs.base.readFile({
          target: config.target,
          encoding: config.encoding,
        });
        config.content = merge(cson.parse(data), config.content);
        log({
          message: "Target Merged",
          level: "DEBUG",
        });
      } catch (error) {
        if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
          throw error;
        }
        // File does not exists, this is ok, there is simply nothing to merge
        log({
          message: "No Target To Merged",
          level: "DEBUG",
        });
      }
    }
    log({
      message: "Serialize Content",
      level: "DEBUG",
    });
    await this.file({
      content: cson.stringify(config.content),
      target: config.target,
      backup: config.backup,
      gid: config.gid,
      uid: config.uid,
      mode: config.mode,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
