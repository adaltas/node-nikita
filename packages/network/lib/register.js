// Generated by CoffeeScript 2.5.1
// registration of `nikita.network` actions
var registry;

registry = require('@nikitajs/engine/lib/registry');

module.exports = {
  network: {
    http: {
      '': '@nikitajs/network/lib/http'
    },
    tcp: {
      'assert': '@nikitajs/network/lib/tcp/assert',
      'wait': '@nikitajs/network/lib/tcp/wait'
    }
  }
};

(async function() {
  return (await registry.register(module.exports));
})();
