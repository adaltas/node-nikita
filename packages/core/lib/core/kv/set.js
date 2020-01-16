// Generated by CoffeeScript 2.5.0
// # `nikita.kv.set`

// ## Source Code
module.exports = function({options}) {
  this.log({
    message: "Entering kv set",
    level: 'DEBUG',
    module: 'nikita/lib/core/kv/set'
  });
  if (options.engine && this.options.kv) {
    throw Error("Engine already defined");
  }
  if (!options.engine && !this.options.kv) {
    throw Error("No engine defined");
  }
  // @options.kv ?= options.engine
  return this.options.kv.set(options.key, options.value);
};
