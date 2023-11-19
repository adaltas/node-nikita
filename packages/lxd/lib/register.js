
// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
import '@nikitajs/file/register';
import '@nikitajs/network/register';

// Actions
const actions = {
  lxc: {
    cluster: {
      '': '@nikitajs/lxd/cluster',
      stop: '@nikitajs/lxd/cluster/stop',
      delete: '@nikitajs/lxd/cluster/delete'
    },
    config: {
      device: {
        '': '@nikitajs/lxd/config/device',
        delete: '@nikitajs/lxd/config/device/delete',
        exists: '@nikitajs/lxd/config/device/exists',
        show: '@nikitajs/lxd/config/device/show'
      },
      set: '@nikitajs/lxd/config/set'
    },
    exists: '@nikitajs/lxd/exists',
    init: '@nikitajs/lxd/init',
    info: '@nikitajs/lxd/info',
    delete: '@nikitajs/lxd/delete',
    start: '@nikitajs/lxd/start',
    state: '@nikitajs/lxd/state',
    stop: '@nikitajs/lxd/stop',
    exec: '@nikitajs/lxd/exec',
    file: {
      exists: '@nikitajs/lxd/file/exists',
      pull: '@nikitajs/lxd/file/pull',
      push: '@nikitajs/lxd/file/push',
      read: '@nikitajs/lxd/file/read'
    },
    goodies: {
      prlimit: '@nikitajs/lxd/goodies/prlimit'
    },
    network: {
      '': '@nikitajs/lxd/network',
      create: '@nikitajs/lxd/network',
      attach: '@nikitajs/lxd/network/attach',
      detach: '@nikitajs/lxd/network/detach',
      delete: '@nikitajs/lxd/network/delete',
      list: '@nikitajs/lxd/network/list'
    },
    query: '@nikitajs/lxd/query',
    list: '@nikitajs/lxd/list',
    running: '@nikitajs/lxd/running',
    storage: {
      '': '@nikitajs/lxd/storage',
      delete: '@nikitajs/lxd/storage/delete',
      exists: '@nikitajs/lxd/storage/exists',
      list: '@nikitajs/lxd/storage/list',
      volume: {
        '': '@nikitajs/lxd/storage/volume',
        delete: '@nikitajs/lxd/storage/volume/delete',
        list: '@nikitajs/lxd/storage/volume/list',
        get: '@nikitajs/lxd/storage/volume/get',
        attach: '@nikitajs/lxd/storage/volume/attach'
      }
    },
    wait: {
      ready: '@nikitajs/lxd/wait/ready'
    },
    resources: '@nikitajs/lxd/resources'
  }
};

await registry.register(actions)
