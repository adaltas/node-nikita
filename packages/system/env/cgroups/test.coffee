
module.exports =
  tags:
    system_cgroups: true
  # service:
  #   name: 'cronie'
  #   srv_name: 'crond'
  #   chk_name: 'crond'
  ssh: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_ed25519'
  ]
