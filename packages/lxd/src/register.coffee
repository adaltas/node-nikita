
require('@nikitajs/core/lib/registry')
.register
  lxd:
    delete:  '@nikitajs/lxd/src/delete'
    init:    '@nikitajs/lxd/src/init'
    network: '@nikitajs/lxd/src/network'
