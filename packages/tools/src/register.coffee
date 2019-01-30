
registry = require '@nikitajs/core/lib/registry'

registry.register
  tools:
    backup: '@nikitajs/tools/src/backup'
    compress: '@nikitajs/tools/src/compress'
    extract: '@nikitajs/tools/src/extract'
    rubygems:
      'fetch': '@nikitajs/tools/src/rubygems/fetch'
      'install': '@nikitajs/tools/src/rubygems/install'
      'remove': '@nikitajs/tools/src/rubygems/remove'
    iptables: '@nikitajs/tools/src/iptables'
    git: '@nikitajs/tools/src/git'
    repo: '@nikitajs/tools/src/repo'
    sysctl: '@nikitajs/tools/src/sysctl'
