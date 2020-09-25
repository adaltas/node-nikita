
# registration of `nikita.network` actions

registry = require '@nikitajs/engine/src/registry'

module.exports =
  network:
    http:
      '': '@nikitajs/network/src/http'
    tcp:
      'assert': '@nikitajs/network/src/tcp/assert'
      'wait': '@nikitajs/network/src/tcp/wait'
(->
  await registry.register module.exports
)()
