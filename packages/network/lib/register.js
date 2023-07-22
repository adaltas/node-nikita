
// Dependencies
const registry = require('@nikitajs/core/lib/registry');

// Action registration
module.exports = {
  network: {
    http: {
      '': '@nikitajs/network/lib/http',
      'wait': '@nikitajs/network/lib/http/wait'
    },
    tcp: {
      'assert': '@nikitajs/network/lib/tcp/assert',
      'wait': '@nikitajs/network/lib/tcp/wait'
    }
  }
};

(async function() {
  try {
    return (await registry.register(module.exports));
  } catch (error) {
    console.error(error.stack);
    return process.exit(1);
  }
})();
