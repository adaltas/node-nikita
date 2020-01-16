// Generated by CoffeeScript 2.5.0
// # `nikita.lxd.running`

// Start containers.

// ## Options

// * `container` (string, required)
//   The name of the container.

// ## Callback Parameters

// * `err`
//   Error object if any.
// * `info.status`
//   Was the container started or already running.

// ## Example

// ```
// require('nikita')
// .lxd.running({
//   container: "my_container"
// }, function(err, {status}) {
//   console.log( err ? err.message :
//     status ? 'Container is running' : 'Container is not running' )
// });
// ```

// ## Source Code
var validate_container_name;

module.exports = {
  shy: true,
  handler: function({options}) {
    this.log({
      message: "Entering lxd.init",
      level: 'DEBUG',
      module: '@nikitajs/lxd/lib/init'
    });
    if (!options.container) {
      // Validation
      throw Error("Invalid Option: container is required");
    }
    validate_container_name(options.container);
    return this.system.execute({
      container: options.container,
      cmd: `lxc list -c ns --format csv | grep '${options.container},RUNNING' || exit 42`,
      code_skipped: 42
    });
  }
};

// ## Dependencies
validate_container_name = require('./misc/validate_container_name');
