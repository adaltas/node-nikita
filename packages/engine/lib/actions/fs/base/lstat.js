// Generated by CoffeeScript 2.5.1
// # `nikita.fs.base.lstat`

// Retrieve file information. If path is a symbolic link, then the link itself is
// stated, not the file that it refers to.

// ## Hook
var handler, on_action, schema;

on_action = function({config, metadata}) {
  if (metadata.argument != null) {
    return config.target = metadata.argument;
  }
};

// ## Schema
schema = {
  type: 'object',
  properties: {
    'target': {
      type: 'string',
      description: `Location of the file from where to obtain information.`
    }
  },
  required: ['target']
};

// ## Handler
handler = async function({config}) {
  return (await this.fs.base.stat({
    target: config.target,
    dereference: false
  }));
};

// ## Exports
module.exports = {
  handler: handler,
  hooks: {
    on_action: on_action
  },
  metadata: {
    log: false,
    raw_output: true,
    schema: schema
  }
};
