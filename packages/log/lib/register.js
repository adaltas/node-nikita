
// Dependencies
const registry = require('@nikitajs/core/lib/registry');

// Action registration
module.exports = {
  log: {
    cli: '@nikitajs/log/lib/cli',
    csv: '@nikitajs/log/lib/csv',
    fs: '@nikitajs/log/lib/fs',
    md: '@nikitajs/log/lib/md',
    stream: '@nikitajs/log/lib/stream'
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
