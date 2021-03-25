// Generated by CoffeeScript 2.5.1
// # `nikita.docker.start`

// Start a container.

// ## Output

// * `err`   
//   Error object if any.
// * `$status`   
//   True unless container was already started.
// * `stdout`   
//   Stdout value(s) unless `stdout` option is provided.
// * `stderr`   
//   Stderr value(s) unless `stderr` option is provided.

// ## Example

// ```js
// const {$status} = await nikita.docker.start({
//   container: 'toto',
//   attach: true
// })
// console.info(`Container was started: ${$status}`)
// ```

// ## Schema
var handler, schema;

schema = {
  type: 'object',
  properties: {
    'attach': {
      type: 'boolean',
      default: false,
      description: `Attach STDOUT/STDERR.`
    },
    'container': {
      type: 'string',
      description: `Name/ID of the container, required.`
    },
    'docker': {
      $ref: 'module://@nikitajs/docker/lib/tools/execute#/definitions/docker'
    }
  },
  required: ['container']
};

// ## Handler
handler = async function({
    config,
    tools: {log}
  }) {
  var $status;
  ({$status} = (await this.docker.tools.status(config, {
    $shy: true
  })));
  if ($status) {
    log({
      message: `Container already started ${config.container} (Skipping)`,
      level: 'INFO',
      module: 'nikita/lib/docker/start'
    });
  } else {
    log({
      message: `Starting container ${config.container}`,
      level: 'INFO',
      module: 'nikita/lib/docker/start'
    });
  }
  return (await this.docker.tools.execute({
    $unless: $status,
    command: ['start', config.attach ? '-a' : void 0, `${config.container}`].join(' ')
  }));
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    global: 'docker',
    schema: schema
  }
};
