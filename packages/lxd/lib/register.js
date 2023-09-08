
// Dependencies
const registry = require('@nikitajs/core/lib/registry');

// Action registration
require('@nikitajs/file/lib/register');
require('@nikitajs/network/lib/register');
module.exports = {
  lxc: {
    cluster: {
      '': '@nikitajs/lxd/lib/cluster',
      stop: '@nikitajs/lxd/lib/cluster/stop',
      delete: '@nikitajs/lxd/lib/cluster/delete'
    },
    config: {
      device: {
        '': '@nikitajs/lxd/lib/config/device',
        delete: '@nikitajs/lxd/lib/config/device/delete',
        exists: '@nikitajs/lxd/lib/config/device/exists',
        show: '@nikitajs/lxd/lib/config/device/show'
      },
      set: '@nikitajs/lxd/lib/config/set'
    },
    exists: '@nikitajs/lxd/lib/exists',
    init: '@nikitajs/lxd/lib/init',
    info: '@nikitajs/lxd/lib/info',
    delete: '@nikitajs/lxd/lib/delete',
    start: '@nikitajs/lxd/lib/start',
    state: '@nikitajs/lxd/lib/state',
    stop: '@nikitajs/lxd/lib/stop',
    exec: '@nikitajs/lxd/lib/exec',
    file: {
      exists: '@nikitajs/lxd/lib/file/exists',
      pull: '@nikitajs/lxd/lib/file/pull',
      push: '@nikitajs/lxd/lib/file/push',
      read: '@nikitajs/lxd/lib/file/read'
    },
    goodies: {
      prlimit: '@nikitajs/lxd/lib/goodies/prlimit'
    },
    network: {
      '': '@nikitajs/lxd/lib/network',
      create: '@nikitajs/lxd/lib/network',
      attach: '@nikitajs/lxd/lib/network/attach',
      detach: '@nikitajs/lxd/lib/network/detach',
      delete: '@nikitajs/lxd/lib/network/delete',
      list: '@nikitajs/lxd/lib/network/list'
    },
    query: '@nikitajs/lxd/lib/query',
    list: '@nikitajs/lxd/lib/list',
    running: '@nikitajs/lxd/lib/running',
    storage: {
      '': '@nikitajs/lxd/lib/storage',
      delete: '@nikitajs/lxd/lib/storage/delete',
      exists: '@nikitajs/lxd/lib/storage/exists',
      list: '@nikitajs/lxd/lib/storage/list',
      volume: {
        '': '@nikitajs/lxd/lib/storage/volume',
        delete: '@nikitajs/lxd/lib/storage/volume/delete',
        list: '@nikitajs/lxd/lib/storage/volume/list',
        get: '@nikitajs/lxd/lib/storage/volume/get',
        attach: '@nikitajs/lxd/lib/storage/volume/attach'
      }
    },
    wait: {
      ready: '@nikitajs/lxd/lib/wait/ready'
    },
    resources: '@nikitajs/lxd/lib/resources'
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
