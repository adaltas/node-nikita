// Generated by CoffeeScript 2.5.1
// # `nikita.docker.stop`

// Stop a started container.

// ## Options

// * `boot2docker` (boolean)   
//   Whether to use boot2docker or not, default to false.
// * `container` (string)   
//   Name/ID of the container, required.
// * `machine` (string)   
//   Name of the docker-machine, required if using docker-machine.
// * `timeout` (int)   
//   Seconds to wait for stop before killing it

// ## Callback parameters

// * `err`   
//   Error object if any.
// * `status`   
//   True unless container was already stopped.

// ## Example

// ```javascript
// require('nikita')
// .docker.stop({
//   container: 'toto'
// }, function(err, {status}){
//   console.log( err ? err.message : 'Container state changed to stopped: ' + status);
// })
// ```

// ## Schema
var docker, handler, schema, util;

schema = {
  type: 'object',
  properties: {}
};

// ## Handler
handler = function({
    config,
    log,
    operations: {find}
  }) {
  var cmd, k, ref, v;
  log({
    message: "Entering Docker stop",
    level: 'DEBUG',
    module: 'nikita/lib/docker/stop'
  });
  // Global config
  if (config.docker == null) {
    config.docker = {};
  }
  ref = config.docker;
  for (k in ref) {
    v = ref[k];
    if (config[k] == null) {
      config[k] = v;
    }
  }
  if (config.container == null) {
    // Validate parameters
    throw Error('Missing container parameter');
  }
  // rm is false by default only if config.service is true
  cmd = 'stop';
  if (config.timeout != null) {
    cmd += ` -t ${config.timeout}`;
  }
  cmd += ` ${config.container}`;
  this.docker.status({
    shy: true
  }, config, function(err, {status}) {
    if (err) {
      throw err;
    }
    if (status) {
      log({
        message: `Stopping container ${config.container}`,
        level: 'INFO',
        module: 'nikita/lib/docker/stop'
      });
    } else {
      log({
        message: `Container already stopped ${config.container} (Skipping)`,
        level: 'INFO',
        module: 'nikita/lib/docker/stop'
      });
    }
    if (!status) {
      return this.end();
    }
  });
  return this.execute({
    cmd: docker.wrap(config, cmd)
  }, docker.callback);
};

// ## Exports
module.exports = {
  handler: handler,
  schema: schema
};

// ## Dependencies
docker = require('./utils');

util = require('util');
