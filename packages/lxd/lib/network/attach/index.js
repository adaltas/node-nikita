// Dependencies
const dedent = require('dedent');
const definitions = require('./schema.json');
const esa = require('../../utils').string.escapeshellarg;

// Action
module.exports = {
  handler: async function({config}) {
    //Build command
    const command_attach = [
      "lxc",
      "network",
      "attach",
      esa(config.network),
      esa(config.container),
    ].join(" ");
    //Execute
    return (await this.execute({
      command: dedent`
        lxc config device list ${esa(config.container)} | grep ${esa(config.network)} && exit 42
        ${command_attach}
      `,
      code: [0, 42]
    }));
  },
  metadata: {
    definitions: definitions
  }
};
