// Generated by CoffeeScript 2.5.1
// # `nikita.lxc.goodies.prlimit`

// Print the process limit associated with a running container.

// Note, the command must be executed on the host container of the machine. When
// using a remote LXD server or cluster, you must know on which node the machine is running
// and run the action in this node.

// ## Output

// * `error` (object)
//   The error object, if any.
// * `output.stdout` (string)
//   The standard output from the `prlimit` command.
// * `output.limits` (array)
//   The limit object parsed from `stdout`; each element of the array contains the
//   keys `resource`, `description`, `soft`, `hard` and `units`.

// ## Example

// ```js
// const {stdout, limits} = await nikita.lxc.goodies.prlimit({
//   container: "my_container"
// })
// console.info( `${stdout} ${JSON.decode(limits)}`)
// ```

// ## Schema
var errors, handler, schema, utils;

schema = {
  type: 'object',
  properties: {
    'container': {
      $ref: 'module://@nikitajs/lxd/lib/init#/properties/container'
    }
  },
  required: ['container']
};

// ## Handler
handler = async function({config}) {
  var description, err, hard, i, limits, line, resource, soft, stdout, units;
  try {
    ({stdout} = (await this.execute({
      command: `command -p prlimit || exit 3
sudo prlimit -p $(lxc info ${config.container} | awk '$1==\"Pid:\"{print $2}')`
    })));
    limits = (function() {
      var j, len, ref, results;
      ref = utils.string.lines(stdout);
      results = [];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        line = ref[i];
        if (i === 0) {
          continue;
        }
        [resource, description, soft, hard, units] = line.split(/\s+/);
        results.push({
          resource: resource,
          description: description,
          soft: soft,
          hard: hard,
          units: units
        });
      }
      return results;
    })();
    return {
      stdout: stdout,
      limits: limits
    };
  } catch (error) {
    err = error;
    if (err.exit_code === 3) {
      err = errors.NIKITA_LXC_PRLIMIT_MISSING();
    }
    throw err;
  }
};

// ## Errors
errors = {
  NIKITA_LXC_PRLIMIT_MISSING: function() {
    return utils.error('NIKITA_LXC_PRLIMIT_MISSING', ['this action requires prlimit installed on the host']);
  }
};

// ## Export
module.exports = {
  handler: handler,
  metadata: {
    schema: schema,
    shy: true
  }
};

// ## Dependencies
utils = require('../utils');
