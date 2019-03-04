
require('@nikitajs/core/lib/registry')
.register
  ipa:
    user:
      '': '@nikitajs/ipa/src/user'
      del: '@nikitajs/ipa/src/user/del'
      exists: '@nikitajs/ipa/src/user/exists'
      show: '@nikitajs/ipa/src/user/show'
