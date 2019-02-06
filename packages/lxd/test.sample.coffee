
module.exports =
  tags:
    lxd: false
    lxd_init: true
    lxd_delete: true
    lxd_network: false
    lxd_start: false
    lxd_stop: false
  ssh:
    host: '127.0.0.1'
    username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
