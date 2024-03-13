// Dependencies
import dedent from "dedent";
import yaml from 'js-yaml';
import diff from 'object-diff';
import {merge} from 'mixme';
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// ## Exports
export default {
  handler: async function({config}) {
    // Normalize config
    for (const key in config.properties) {
      config.properties[key] = config.properties[key].toString();
    }
    // Command if the network does not yet exist
    let { stdout, code, $status } = await this.execute({
      // return code 5 indicates a version of incus where 'network' command is not implemented
      command: dedent`
        incus network 2>/dev/null || exit 5
        incus network show ${config.network} && exit 42
        ${[
          "incus",
          "network",
          "create",
          config.network,
          ...Object.keys(config.properties).map(
            (key) => esa(key) + "=" + esa(config.properties[key])
          ),
        ].join(" ")}
      `,
      code: [0, [5, 42]],
    });
    if (code === 5) {
      throw Error("This version of incus does not support the network command.");
    }
    // Network was created
    if (code === 0) {
      return true;
    }
    // Network already exists, find the changes
    if (!(config != null ? config.properties : void 0)) {
      return;
    }
    const current = yaml.load(stdout);
    const changes = diff(
      current.config,
      merge(current.config, config.properties)
    );
    if (Object.keys(changes).length === 0){
      return false
    }
    for (const key in changes) {
      const value = changes[key];
      await this.execute({
        command: [
          "incus",
          "network",
          "set",
          esa(config.network),
          esa(key),
          esa(value),
        ].join(" "),
      });
    }
    return true;
  },
  metadata: {
    definitions: definitions
  }
};
