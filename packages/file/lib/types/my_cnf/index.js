// Dependencies
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    return await this.file.ini({
      stringify: utils.ini.stringify_single_key
    }, config);
  },
  metadata: {
    definitions: definitions
  }
};
