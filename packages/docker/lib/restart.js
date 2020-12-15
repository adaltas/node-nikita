// Generated by CoffeeScript 2.5.1
// # `nikita.docker.restart`

// Start stopped containers or restart (stop + starts) a started container.

// ## Callback parameters

// * `err`   
//   Error object if any.   
// * `status`   
//   True if container was restarted.  

// ## Example

// ```js
// const {status} = await nikita.docker.restart({
//   container: 'toto'
// })
// console.info(`Container was started or restarted: ${status}`)
// ```

// ## Schema
var handler, schema;

schema = {
  type: 'object',
  properties: {
    'container': {
      type: 'string',
      description: `Name/ID of the container.`
    },
    'timeout': {
      type: 'integer',
      description: `Seconds to wait for stop before killing it.`
    },
    'boot2docker': {
      $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/boot2docker'
    },
    'compose': {
      $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/compose'
    },
    'machine': {
      $ref: 'module://@nikitajs/docker/src/tools/execute#/properties/machine'
    }
  },
  required: ['container']
};

// ## Handler
handler = function({
    config,
    tools: {log}
  }) {
  log({
    message: "Entering Docker restart",
    level: 'DEBUG',
    module: 'nikita/lib/docker/restart'
  });
  return this.docker.tools.execute({
    command: ['restart', config.timeout != null ? `-t ${config.timeout}` : void 0, `${config.container}`].join(' ')
  });
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    global: 'docker',
    schema: schema
  }
};
