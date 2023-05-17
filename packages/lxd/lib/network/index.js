// Dependencies
const dedent = require("dedent");
const yaml = require('js-yaml');
const diff = require('object-diff');
const {merge} = require('mixme');
const definitions = require("./schema.json");
const isa = require('../utils').string.escapeshellarg;

// ## Exports
module.exports = {
  handler: async function({config}) {
    // Normalize config
    for (const key in config.properties) {
      config.properties[key] = config.properties[key].toString();
    }
    // Command if the network does not yet exist
    let { stdout, code, $status } = await this.execute({
      // return code 5 indicates a version of lxc where 'network' command is not implemented
      command: dedent`
        lxc network 2>/dev/null || exit 5
        lxc network show ${config.network} && exit 42
        ${[
          "lxc",
          "network",
          "create",
          config.network,
          ...Object.keys(config.properties).map(
            (key) => isa(key) + "=" + isa(config.properties[key])
          ),
        ].join(" ")}
      `,
      code: [0, [5, 42]],
    });
    if (code === 5) {
      throw Error("This version of lxc does not support the network command.");
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
          "lxc",
          "network",
          "set",
          isa(config.network),
          isa(key),
          isa(value),
        ].join(" "),
      });
    }
    return true;
  },
  metadata: {
    definitions: definitions
  }
};
