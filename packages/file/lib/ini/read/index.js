// Dependencies
import {merge} from 'mixme';
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const parse = config.parse || utils.ini.parse;
    const {data} = (await this.fs.base.readFile({
      target: config.target,
      encoding: config.encoding
    }));
    return {
      data: merge(parse(data, config))
    };
  },
  metadata: {
    definitions: definitions
  }
};
