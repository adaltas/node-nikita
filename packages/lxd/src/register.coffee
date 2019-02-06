
require('@nikitajs/core/lib/registry')
.register
  lxc:
    delete:  '@nikitajs/lxc/src/delete'
    init:    '@nikitajs/lxc/src/init'
    network: '@nikitajs/lxc/src/network'
