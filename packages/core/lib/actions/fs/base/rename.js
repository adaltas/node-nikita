// Generated by CoffeeScript 2.5.1
// # `nikita.fs.base.rename`

// Change the name or location of a file.

// ## Schema definitions
var definitions, handler;

definitions = {
  config: {
    type: 'object',
    properties: {
      'source': {
        type: 'string',
        description: `Location of the file to rename.`
      },
      'target': {
        type: 'string',
        description: `New name of the file.`
      }
    },
    required: ['source', 'target']
  }
};

// ## Handler
handler = async function({config}) {
  return (await this.execute({
    command: `mv ${config.source} ${config.target}`,
    trim: true
  }));
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
