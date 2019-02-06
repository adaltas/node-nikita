
module.exports =
  tags:
    lxc_init: true
    lxc_delete: true
    lxc_network: false
    lxc_start: false
    lxc_stop: false
  ssh:
    host: '127.0.0.1'
    username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
