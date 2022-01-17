
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
    { ssh: host: 'localhost', username: 'root' }
  ]
