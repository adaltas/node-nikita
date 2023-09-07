
// Dependencies
require('@nikitajs/file/lib/register');
const registry = require('@nikitajs/core/lib/registry');

// Action registration
module.exports = {
  java: {
    keystore_add: '@nikitajs/java/lib/keystore_add',
    keystore_remove: '@nikitajs/java/lib/keystore_remove'
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
