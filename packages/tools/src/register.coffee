
# registration of `nikita.tools` actions

require '@nikitajs/file/src/register'
registry = require '@nikitajs/engine/src/registry'

module.exports =
  tools:
    # apm:
    #   'installed': '@nikitajs/tools/src/apm/installed'
    #   'install': '@nikitajs/tools/src/apm/install'
    #   'uninstall': '@nikitajs/tools/src/apm/uninstall'
    backup: '@nikitajs/tools/src/backup'
    compress: '@nikitajs/tools/src/compress'
    # cron:
    #   add: '@nikitajs/tools/src/cron/add'
    #   remove: '@nikitajs/tools/src/cron/remove'
    extract: '@nikitajs/tools/src/extract'
    dconf: '@nikitajs/tools/lib/dconf'
    # iptables: '@nikitajs/tools/src/iptables'
    git: '@nikitajs/tools/src/git'
    npm:
      '': '@nikitajs/tools/src/npm'
      uninstall: '@nikitajs/tools/src/npm/uninstall'
    repo: '@nikitajs/tools/src/repo'
    rubygems:
      'fetch': '@nikitajs/tools/src/rubygems/fetch'
      'install': '@nikitajs/tools/src/rubygems/install'
      'remove': '@nikitajs/tools/src/rubygems/remove'
    ssh:
      keygen: '@nikitajs/tools/src/ssh/keygen'
    sysctl: '@nikitajs/tools/src/sysctl'
(->
  await registry.register module.exports
)()
