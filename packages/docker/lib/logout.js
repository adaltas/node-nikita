// Generated by CoffeeScript 2.5.1
// # `nikita.docker.logout`

// Log out from a Docker registry or the one defined by the `registry` option.

// ## Callback parameters

// * `err`   
//   Error object if any.   
// * `status`   
//   True if logout.

// ## Schema
var handler, schema, utils;

schema = {
  type: 'object',
  properties: {
    'boot2docker': {
      $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
    },
    'compose': {
      $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
    },
    'machine': {
      $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
    },
    'registry': {
      type: 'string',
      description: `Address of the registry server, default to "https://index.docker.io/v1/".`
    }
  }
};

// ## Handler
handler = async function({
    config,
    tools: {log}
  }) {
  var command;
  log({
    message: "Entering Docker logout",
    level: 'DEBUG',
    module: 'nikita/lib/docker/logout'
  });
  if (config.container == null) {
    // Validate parameters
    return callback(Error('Missing container parameter'));
  }
  // rm is false by default only if config.service is true
  command = 'logout';
  if (config.registry != null) {
    command += ` \"${config.registry}\"`;
  }
  return (await this.execute({
    command: utils.wrap(config, command)
  }, docker.callback));
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    global: 'docker',
    schema: schema
  }
};

// ## Dependencies
utils = require('./utils');
