
# Registration of `nikita.lxd` actions

require '@nikitajs/file/lib/register'
require '@nikitajs/network/lib/register'
registry = require '@nikitajs/core/lib/registry'

module.exports =
  lxc:
    cluster:
      '': '@nikitajs/lxd/src/cluster'
      stop: '@nikitajs/lxd/src/cluster/stop'
      delete: '@nikitajs/lxd/src/cluster/delete'
    config:
      device:
        '': '@nikitajs/lxd/src/config/device'
        delete: '@nikitajs/lxd/src/config/device/delete'
        exists: '@nikitajs/lxd/src/config/device/exists'
        show: '@nikitajs/lxd/src/config/device/show'
      set: '@nikitajs/lxd/src/config/set'
    init: '@nikitajs/lxd/src/init'
    delete: '@nikitajs/lxd/src/delete'
    start: '@nikitajs/lxd/src/start'
    state: '@nikitajs/lxd/src/state'
    stop: '@nikitajs/lxd/src/stop'
    exec: '@nikitajs/lxd/src/exec'
    file:
      exists: '@nikitajs/lxd/src/file/exists'
      pull: '@nikitajs/lxd/src/file/pull'
      push: '@nikitajs/lxd/src/file/push'
      read: '@nikitajs/lxd/src/file/read'
    goodies:
      prlimit: '@nikitajs/lxd/src/goodies/prlimit'
    network:
      '': '@nikitajs/lxd/src/network'
      create: '@nikitajs/lxd/src/network'
      attach: '@nikitajs/lxd/src/network/attach'
      detach: '@nikitajs/lxd/src/network/detach'
      delete: '@nikitajs/lxd/src/network/delete'
      list: '@nikitajs/lxd/src/network/list'
    query: '@nikitajs/lxd/src/query'
    list: '@nikitajs/lxd/src/list'
    running: '@nikitajs/lxd/src/running'
    storage:
      '': '@nikitajs/lxd/src/storage'
      delete: '@nikitajs/lxd/src/storage/delete'
      volume:
        '': '@nikitajs/lxd/src/storage/volume'
        delete: '@nikitajs/lxd/src/storage/volume/delete' 
        list: '@nikitajs/lxd/src/storage/volume/list' 
        get: '@nikitajs/lxd/src/storage/volume/get'
        attach: '@nikitajs/lxd/src/storage/volume/attach'
    wait:
      ready: '@nikitajs/lxd/src/wait/ready'
    resources: '@nikitajs/lxd/src/resources'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
