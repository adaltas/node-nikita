
# registration of `nikita.lxd` actions

require '@nikitajs/file/src/register'
require '@nikitajs/network/src/register'
registry = require '@nikitajs/engine/src/registry'

module.exports =
  lxd:
    cluster:
      '': '@nikitajs/lxd/src/cluster'
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
      push: '@nikitajs/lxd/src/file/push'
      exists: '@nikitajs/lxd/src/file/exists'
    goodies:
      prlimit: '@nikitajs/lxd/src/goodies/prlimit'
    network:
      '': '@nikitajs/lxd/src/network'
      create: '@nikitajs/lxd/src/network'
      attach: '@nikitajs/lxd/src/network/attach'
      detach: '@nikitajs/lxd/src/network/detach'
      delete: '@nikitajs/lxd/src/network/delete'
    query: '@nikitajs/lxd/src/query'
    running: '@nikitajs/lxd/src/running'
    storage:
      '': '@nikitajs/lxd/src/storage'
      delete: '@nikitajs/lxd/src/storage/delete'
(->
  try
    await registry.register module.exports
  catch err
    console.error err.stack
    process.exit(1)
)()
