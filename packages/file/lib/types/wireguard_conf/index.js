// Dependencies
import path from 'node:path'
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    if (config.target == null) {
      config.target = `/etc/wireguard/${config.interface}.conf`;
    }
    if (config.rootdir) {
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    await this.file.ini({
      parse: utils.ini.parse_multi_brackets,
      stringify: utils.ini.stringify_multi_brackets,
      indent: "",
      ...utils.object.filter(config, ['interface', 'rootdir']),
    });
  },
  metadata: {
    definitions: definitions
  }
};
