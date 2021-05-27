// Generated by CoffeeScript 2.5.1
// # `nikita.tools.npm.list`

// List all Node.js packages with NPM.

// ## Schema definitions
var definitions, handler;

definitions = {
  config: {
    type: 'object',
    properties: {
      'cwd': {
        $ref: 'module://@nikitajs/core/lib/actions/execute#/definitions/config/properties/cwd'
      },
      'global': {
        type: 'boolean',
        default: false,
        description: `Upgrades global packages.`
      }
    },
    if: {
      properties: {
        'global': {
          const: false
        }
      }
    },
    then: {
      required: ['cwd']
    }
  }
};

// ## Handler
handler = async function({config}) {
  var stdout;
  ({stdout} = (await this.execute({
    command: ['npm list', '--json', config.global ? '--global' : void 0].join(' '),
    code: [0, 1],
    cwd: config.cwd,
    stdout_log: false
  })));
  return {
    packages: JSON.parse(stdout).dependencies || {}
  };
};


// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    definitions: definitions,
    shy: true
  }
};
