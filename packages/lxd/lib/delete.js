// Generated by CoffeeScript 2.5.1
// # `nikita.lxd.delete`

// Delete a Linux Container using lxd.

// ## Example

// ```js
// const {status} = await nikita.lxd.delete({
//   container: "myubuntu"
// })
// console.info(`Container was deleted: ${status}`)
// ```

// ## Schema
var handler, schema;

schema = {
  type: 'object',
  properties: {
    'container': {
      $ref: 'module://@nikitajs/lxd/src/init#/properties/container'
    },
    'force': {
      type: 'boolean',
      default: false,
      description: `If true, the container will be deleted even if running.`
    }
  },
  required: ['container']
};

// ## Handler
handler = function({config}) {
  // log message: "Entering lxd.delete", level: 'DEBUG', module: '@nikitajs/lxd/lib/delete'
  return this.execute({
    command: `lxc info ${config.container} > /dev/null || exit 42
${['lxc', 'delete', config.container, config.force ? "--force" : void 0].join(' ')}`,
    code_skipped: 42
  });
};

// ## Export
module.exports = {
  handler: handler,
  metadata: {
    schema: schema
  }
};
