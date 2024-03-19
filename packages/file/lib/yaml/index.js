// Dependencies
import utils from "@nikitajs/file/utils";
import yaml from "js-yaml";
import { merge } from "mixme";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    try {
      if (config.merge) {
        const { data } = await this.fs.base.readFile({
          target: config.target,
          encoding: "utf8",
        });
        config.content = merge(yaml.load(data), config.content);
      }
    } catch (error) {
      if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
        throw error;
      }
    }
    if (config.clean) {
      log({
        message: "Cleaning content",
        level: "INFO",
      });
      utils.object.clean(config.content);
    }
    log({
      message: "Serialize content",
      level: "DEBUG",
    });
    config.content = yaml.dump(config.content, {
      indent: config.indent,
      noRefs: true,
      lineWidth: config.line_width,
    });
    await this.file(utils.object.filter(config, ['clean', 'indent', 'line_width', 'merge']));
  },
  metadata: {
    definitions: definitions,
  },
};
