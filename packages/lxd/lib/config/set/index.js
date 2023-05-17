// Dependencies
const {merge} = require('mixme');
const yaml = require('js-yaml');
const diff = require('object-diff');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    // Normalize config
    for (const key in config.properties) {
      const value = config.properties[key];
      if (typeof value === 'string') {
        continue;
      }
      config.properties[key] = value.toString();
    }
    const {stdout} = (await this.execute({
      $shy: true,
      command: `${['lxc', 'config', 'show', config.container].join(' ')}`,
      code: [0, 42]
    }));
    const { config: properties } = yaml.load(stdout);
    const changes = diff(properties, merge(properties, config.properties));
    if (Object.keys(changes).length === 0) return false;
    for (const key in changes) {
      const value = changes[key];
      // if changes is empty status is false because no command were executed
      // Note, it doesnt seem possible to set multiple keys in one command
      await this.execute({
        command: ['lxc', 'config', 'set', config.container, key, `'${value.replace('\'', '\\\'')}'`].join(' ')
      });
    }
    return true;
  },
  metadata: {
    definitions: definitions
  }
};
