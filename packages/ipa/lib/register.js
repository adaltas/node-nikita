
// Dependencies
require('@nikitajs/network/lib/register');
const registry = require('@nikitajs/core/lib/registry');

// Action registration
module.exports = {
  ipa: {
    group: {
      '': '@nikitajs/ipa/lib/group',
      add_member: '@nikitajs/ipa/lib/group/add_member',
      del: '@nikitajs/ipa/lib/group/del',
      exists: '@nikitajs/ipa/lib/group/exists',
      show: '@nikitajs/ipa/lib/group/show'
    },
    user: {
      '': '@nikitajs/ipa/lib/user',
      disable: '@nikitajs/ipa/lib/user/disable',
      del: '@nikitajs/ipa/lib/user/del',
      enable: '@nikitajs/ipa/lib/user/enable',
      exists: '@nikitajs/ipa/lib/user/exists',
      find: '@nikitajs/ipa/lib/user/find',
      show: '@nikitajs/ipa/lib/user/show',
      status: '@nikitajs/ipa/lib/user/status'
    },
    service: {
      '': '@nikitajs/ipa/lib/service',
      del: '@nikitajs/ipa/lib/service/del',
      exists: '@nikitajs/ipa/lib/service/exists',
      show: '@nikitajs/ipa/lib/service/show'
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
