// Dependencies
const definitions = require('./schema.json');
var diff, handler, yaml;

// ## Handler
handler = async function({config}) {
  var $status, changes, code, currentProperties, k, key, ref, stdout, v, value;
  ref = config.properties;
  // Normalize config
  for (k in ref) {
    v = ref[k];
    if (typeof v === 'string') {
      continue;
    }
    config.properties[k] = v.toString();
  }
  // Check if exists
  ({stdout, code} = (await this.execute({
    command: `lxc storage show ${config.name} && exit 42
${[
      'lxc',
      'storage',
      'create',
      config.name,
      config.driver,
      ...((function() {
        var ref1,
      results;
        ref1 = config.properties;
        results = [];
        for (key in ref1) {
          value = ref1[key];
          results.push(`${key}='${value.replace('\'',
      '\\\'')}'`);
        }
        return results;
      })())
    ].join(' ')}`,
    code: [0, 42]
  })));
  if (code !== 42) {
    return;
  }
  // Storage already exists, find the changes
  if (!(config != null ? config.properties : void 0)) {
    return;
  }
  ({
    config: currentProperties
  } = yaml.load(stdout));
  changes = diff(currentProperties, config.properties);
  for (key in changes) {
    value = changes[key];
    // if changes is empty status is false because no command were executed
    ({$status} = (await this.execute({
      command: ['lxc', 'storage', 'set', config.name, key, `'${value.replace('\'', '\\\'')}'`].join(' ')
    })));
  }
  return {
    $status: $status
  };
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    definitions: definitions
  }
};

// ## Dependencies
yaml = require('js-yaml');

diff = require('object-diff');
