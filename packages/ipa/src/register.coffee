
# registration of `nikita.ipa` actions

require '@nikitajs/network/src/register'
registry = require '@nikitajs/engine/src/registry'

module.exports =
  ipa:
    group:
      '': '@nikitajs/ipa/src/group'
      add_member: '@nikitajs/ipa/src/group/add_member'
      del: '@nikitajs/ipa/src/group/del'
      exists: '@nikitajs/ipa/src/group/exists'
      show: '@nikitajs/ipa/src/group/show'
    user:
      '': '@nikitajs/ipa/src/user'
      find: '@nikitajs/ipa/src/user/find'
      del: '@nikitajs/ipa/src/user/del'
      exists: '@nikitajs/ipa/src/user/exists'
      show: '@nikitajs/ipa/src/user/show'
    service:
      '': '@nikitajs/ipa/src/service'
      del: '@nikitajs/ipa/src/service/del'
      exists: '@nikitajs/ipa/src/service/exists'
      show: '@nikitajs/ipa/src/service/show'
(->
  await registry.register module.exports
)()
