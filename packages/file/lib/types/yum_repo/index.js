// Dependencies
import path from "node:path";
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    // Set the target directory to yum's default path if target is a file name
    config.target = path.resolve("/etc/yum.repos.d", config.target);
    await this.file.ini({
      parse: utils.ini.parse_multi_brackets,
      ...config,
      // Dont escape the section's header, headers are only one level and
      // contains versions with dots.
      escape: false,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
