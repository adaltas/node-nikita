// Dependencies
import path from 'node:path'
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    if (config.rootdir) {
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    return await this.file.ini({
      stringify: utils.ini.stringify_single_key
    }, utils.object.filter(config, ['rootdir']));
  },
  metadata: {
    definitions: definitions
  }
};
