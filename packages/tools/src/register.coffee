
registry = require '@nikita/core/lib/registry'

registry.register
  tools:
    backup: '@nikita/tools/src/backup'
    compress: '@nikita/tools/src/compress'
    extract: '@nikita/tools/src/extract'
    rubygems:
      'fetch': '@nikita/tools/src/rubygems/fetch'
      'install': '@nikita/tools/src/rubygems/install'
      'remove': '@nikita/tools/src/rubygems/remove'
    iptables: '@nikita/tools/src/iptables'
    git: '@nikita/tools/src/git'
    repo: '@nikita/tools/src/repo'
    sysctl: '@nikita/tools/src/sysctl'
