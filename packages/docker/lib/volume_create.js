// Generated by CoffeeScript 2.5.0
// # `nikita.volume_create`

// Create a volume. 

// ## Options

// * `boot2docker` (boolean)   
//   Whether to use boot2docker or not, default to false.
// * `driver` (string)   
//   Specify volume driver name.
// * `label` (string|array)   
//   Set metadata for a volume.
// * `machine` (string)   
//   Name of the docker-machine, required if using docker-machine.
// * `name` (string)   
//   Specify volume name.
// * `opt` (string|array)   
//   Set driver specific options.

// ## Callback parameters

// * `err`   
//   Error object if any.   
// * `status`   
//   True is volume was created.

// ## Example

// ```javascript
// require('nikita')
// .docker.pause({
//   name: 'my_volume'
// }, function(err, status){
//   console.log( err ? err.message : 'Volume created: ' + status);
// })
// ```

// ## Source Code
var docker;

module.exports = function({options}) {
  var cmd, k, ref, v;
  this.log({
    message: "Entering Docker volume_create",
    level: 'DEBUG',
    module: 'nikita/lib/docker/volume_create'
  });
  // Global options
  if (options.docker == null) {
    options.docker = {};
  }
  ref = options.docker;
  for (k in ref) {
    v = ref[k];
    if (options[k] == null) {
      options[k] = v;
    }
  }
  if (typeof options.label === 'string') {
    // Normalize options
    options.label = [options.label];
  }
  if (typeof options.opt === 'string') {
    options.opt = [options.opt];
  }
  // Build the docker command arguments
  cmd = ["volume create"];
  if (options.driver) {
    cmd.push(`--driver ${options.driver}`);
  }
  if (options.label) {
    cmd.push(`--label ${options.label.join(',')}`);
  }
  if (options.name) {
    cmd.push(`--name ${options.name}`);
  }
  if (options.opt) {
    cmd.push(`--opt ${options.opt.join(',')}`);
  }
  cmd = cmd.join(' ');
  this.system.execute({
    if: options.name,
    cmd: docker.wrap(options, `volume inspect ${options.name}`),
    code: 1,
    code_skipped: 0,
    shy: true
  });
  return this.system.execute({
    if: function() {
      return !options.name || this.status(-1);
    },
    cmd: docker.wrap(options, cmd)
  });
};

// ## Modules Dependencies
docker = require('@nikitajs/core/lib/misc/docker');
