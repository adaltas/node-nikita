
// Dependencies
const registry = require('@nikitajs/core/lib/registry');

// Action registration
module.exports = {
  db: {
    database: {
      '': '@nikitajs/db/lib/database',
      exists: '@nikitajs/db/lib/database/exists',
      remove: '@nikitajs/db/lib/database/remove',
      wait: '@nikitajs/db/lib/database/wait'
    },
    query: '@nikitajs/db/lib/query',
    schema: {
      '': '@nikitajs/db/lib/schema',
      exists: '@nikitajs/db/lib/schema/exists',
      list: '@nikitajs/db/lib/schema/list',
      remove: '@nikitajs/db/lib/schema/remove'
    },
    user: {
      '': '@nikitajs/db/lib/user',
      exists: '@nikitajs/db/lib/user/exists',
      remove: '@nikitajs/db/lib/user/remove'
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
