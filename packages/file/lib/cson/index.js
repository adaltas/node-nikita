// ## Dependencies
import { merge } from "mixme";
import cson from "cson";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (config.merge) {
      log("DEBUG", "Get Target Content");
      try {
        const { data } = await this.fs.readFile({
          target: config.target,
          encoding: config.encoding,
        });
        config.content = merge(cson.parse(data), config.content);
        log("DEBUG", "Target Merged");
      } catch (error) {
        if (error.code !== "NIKITA_FS_CRS_TARGET_ENOENT") {
          throw error;
        }
        // File does not exists, this is ok, there is simply nothing to merge
        log("DEBUG", "No Target To Merged");
      }
    }
    log("DEBUG", "Serialize Content");
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
