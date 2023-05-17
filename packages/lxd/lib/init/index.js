// Dependencies
const dedent = require('dedent');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    const command_init = [
      "lxc",
      "init",
      config.image,
      config.container,
      config.network && `--network ${config.network}`,
      config.storage && `--storage ${config.storage}`,
      config.ephemeral && "--ephemeral",
      config.vm && "--vm",
      config.profile && `--profile ${config.profile}`,
      config.target && `--target ${config.target}`,
    ].filter(Boolean).join(" ");
    // Execution
    const {$status} = (await this.execute({
      command: dedent`
        lxc info ${config.container} >/dev/null && exit 42
        echo '' | ${command_init}
      `,
      code: [0, 42]
    }));
    await this.lxc.start({
      $if: config.start,
      container: config.container
    });
    return $status;
  },
  metadata: {
    definitions: definitions
  }
};
