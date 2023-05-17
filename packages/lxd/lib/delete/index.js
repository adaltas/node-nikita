// Dependencies
const dedent = require('dedent');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    return (await this.execute({
      command: dedent`
        lxc info ${config.container} > /dev/null || exit 42
        ${['lxc', 'delete', config.container, config.force ? "--force" : void 0].join(' ')}
      `,
      code: [0, 42]
    }));
  },
  metadata: {
    argument_to_config: 'container',
    definitions: definitions
  }
};
