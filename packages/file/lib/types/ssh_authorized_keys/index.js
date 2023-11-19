// ## Dependencies
import path from 'node:path'
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    await this.fs.assert({
      target: path.dirname(config.target)
    });
    if (config.merge) {
      await this.file({
        target: config.target,
        write: config.keys.map(key => ({
          match: new RegExp(`.*${utils.regexp.escape(key)}.*`, 'mg'),
          replace: key,
          append: true
        })),
        uid: config.uid,
        gid: config.gid,
        mode: config.mode,
        eof: true
      });
    } else {
      await this.file({
        target: config.target,
        content: config.keys.join('\n'),
        uid: config.uid,
        gid: config.gid,
        mode: config.mode,
        eof: true
      });
    }
  },
  metadata: {
    definitions: definitions
  }
};
