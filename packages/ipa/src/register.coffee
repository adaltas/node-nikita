
# registration of `nikita.ipa` actions

## Dependency

    {register} = require '@nikitajs/core/lib/registry'

## Action registration

    register module.exports =
      ipa:
        group:
          '': '@nikitajs/ipa/src/group'
          add_member: '@nikitajs/ipa/src/group/add_member'
          del: '@nikitajs/ipa/src/group/del'
          exists: '@nikitajs/ipa/src/group/exists'
          show: '@nikitajs/ipa/src/group/show'
        user:
          '': '@nikitajs/ipa/src/user'
          del: '@nikitajs/ipa/src/user/del'
          exists: '@nikitajs/ipa/src/user/exists'
          find: '@nikitajs/ipa/src/user/find'
          show: '@nikitajs/ipa/src/user/show'
