// Dependencies
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    return await this.file.ini({
      parse: utils.ini.parse_brackets_then_curly,
      stringify: utils.ini.stringify_brackets_then_curly
    }, config);
  },
  metadata: {
    definitions: definitions
  }
};
