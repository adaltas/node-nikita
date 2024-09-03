// Dependencies
import utils from "@nikitajs/file/utils";
import yaml from "js-yaml";
import { merge } from "mixme";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    try {
      if (config.merge) {
        const { data } = await this.fs.readFile({
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
      log("Cleaning content");
      utils.object.clean(config.content);
    }
    log("DEBUG", "Serialize content");
    config.content = yaml.dump(config.content, {
      indent: config.indent,
      noRefs: true,
      lineWidth: config.line_width,
    });
    await this.file(
      utils.object.filter(config, ["clean", "indent", "line_width", "merge"]),
    );
  },
  metadata: {
    definitions: definitions,
  },
};
