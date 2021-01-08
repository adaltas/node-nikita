// Generated by CoffeeScript 2.5.1
// # `nikita.docker.kill`

// Send signal to containers using SIGKILL or a specified signal.
// Note if container is not running , SIGKILL is not executed and
// return status is UNMODIFIED. If container does not exist nor is running
// SIGNAL is not sent.

// ## Output

// * `err`   
//   Error object if any.
// * `status`   
//   True if container was killed.

// ## Example

// ```js
// const {status} = await nikita.docker.kill({
//   container: 'toto',
//   signal: 9
// })
// console.info(`Container was killed: ${status}`)
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
    'docker': {
      $ref: 'module://@nikitajs/docker/lib/tools/execute#/properties/docker'
    },
    'signal': {
      oneOf: [
        {
          type: 'integer'
        },
        {
          type: 'string'
        }
      ],
      description: `Use a specified signal. SIGKILL by default.`
    }
  },
  required: ['container']
};

// ## Handler
handler = async function({config}) {
  var status;
  ({status} = (await this.docker.tools.execute({
    command: `ps | egrep ' ${config.container}$' | grep 'Up'`,
    code_skipped: 1
  })));
  return (await this.docker.tools.execute({
    if: function() {
      return status;
    },
    command: ['kill', config.signal != null ? `-s ${config.signal}` : void 0, `${config.container}`].join(' ')
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
