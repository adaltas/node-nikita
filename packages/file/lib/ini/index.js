// Dependencies
import utils from "@nikitajs/file/utils";
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
    let org_props = {};
    const parse = config.parse || utils.ini.parse;
    const stringify = config.stringify || utils.ini.stringify;
    try {
      // Original properties
      const { data } = await this.fs.readFile({
        target: config.target,
        encoding: config.encoding,
      });
      org_props = parse(data, config);
    } catch (error) {
      if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
        throw error;
      }
    }
    try {
      // Default properties
      if (config.source) {
        const { data } = await this.fs.readFile({
          $if: config.source,
          $ssh: config.local ? false : void 0,
          $sudo: config.local ? false : void 0,
          target: config.source,
          encoding: config.encoding,
        });
        // content = utils.object.clean(config.content, true);
        config.content = merge(parse(data, config), config.content);
      }
    } catch (error) {
      if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
        throw error;
      }
    }
    // Merge
    if (config.merge) {
      config.content = merge(org_props, config.content);
      log("DEBUG", "Get content for merge");
    }
    if (config.clean) {
      log("Clean content");
      utils.object.clean(config.content);
    }
    log("DEBUG", "Serialize content");
    return await this.file({
      target: config.target,
      content: stringify(config.content, config),
      backup: config.backup,
      diff: config.diff,
      eof: config.eof,
      gid: config.gid,
      uid: config.uid,
      mode: config.mode,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
