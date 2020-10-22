
# registration of `nikita.tools` actions

registry = require '@nikitajs/engine/src/registry'

module.exports =
  tools:
    npm:
      '': '@nikitajs/tools/src/npm'
      uninstall: '@nikitajs/tools/src/npm/uninstall'
    rubygems:
      'fetch': '@nikitajs/tools/src/rubygems/fetch'
      'install': '@nikitajs/tools/src/rubygems/install'
      'remove': '@nikitajs/tools/src/rubygems/remove'
    ssh:
      keygen: '@nikitajs/tools/src/ssh/keygen'
(->
  await registry.register module.exports
)()

# register module.exports =
  # tools:
    # backup: '@nikitajs/tools/src/backup'
    # compress: '@nikitajs/tools/src/compress'
    # cron:
    #   add: '@nikitajs/tools/src/cron/add'
    #   remove: '@nikitajs/tools/src/cron/remove'
    # extract: '@nikitajs/tools/src/extract'
    # dconf: '@nikitajs/tools/lib/dconf'
    # rubygems:
      # 'fetch': '@nikitajs/tools/src/rubygems/fetch'
      # 'install': '@nikitajs/tools/src/rubygems/install'
      # 'remove': '@nikitajs/tools/src/rubygems/remove'
    # iptables: '@nikitajs/tools/src/iptables'
    # git: '@nikitajs/tools/src/git'
    # repo: '@nikitajs/tools/src/repo'
    # ssh:
    #   keygen: '@nikitajs/tools/src/ssh/keygen'
    # sysctl: '@nikitajs/tools/src/sysctl'
    # npm:
    #   '': '@nikitajs/tools/src/npm'
    #   uninstall: '@nikitajs/tools/src/npm/uninstall'
    # apm:
    #   'install': '@nikitajs/tools/src/apm/install'
    #   'uninstall': '@nikitajs/tools/src/apm/uninstall'
