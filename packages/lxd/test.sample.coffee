
module.exports =
  tags:
    lxd: true
    lxd_prlimit: true
  ssh: [
    null
    { host: '127.0.0.1', username: process.env.USER }
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
    # {
    #   host: '127.0.0.1', port: 2222, username: 'vagrant'
    #   private_key_path: "#{require('os').homedir()}/.vagrant.d/insecure_private_key"
    # }
    # {
    #   host: '127.0.0.1', port: 2200, username: 'nikita'
    #   private_key_path: __dirname + '/../core/env/lxccentos7/assets/id_rsa'
    # }
  ]
