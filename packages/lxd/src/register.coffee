
require('@nikitajs/core/lib/registry')
.register
  lxd:
    exec: '@nikitajs/lxd/src/exec'
    delete: '@nikitajs/lxd/src/delete'
    file:
      exists: '@nikitajs/lxd/src/file/exists'
      push: '@nikitajs/lxd/src/file/push'
    init: '@nikitajs/lxd/src/init'
    network: '@nikitajs/lxd/src/network'
    start: '@nikitajs/lxd/src/start'
    stop: '@nikitajs/lxd/src/stop'
