
// Dependencies
const registry = require('@nikitajs/core/lib/registry');

// Action registration
module.exports = {
  service: {
    '': '@nikitajs/service/lib',
    assert: '@nikitajs/service/lib/assert',
    discover: '@nikitajs/service/lib/discover',
    install: '@nikitajs/service/lib/install',
    init: '@nikitajs/service/lib/init',
    remove: '@nikitajs/service/lib/remove',
    restart: '@nikitajs/service/lib/restart',
    start: '@nikitajs/service/lib/start',
    startup: '@nikitajs/service/lib/startup',
    status: '@nikitajs/service/lib/status',
    stop: '@nikitajs/service/lib/stop'
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
