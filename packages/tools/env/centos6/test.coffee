
module.exports =
  tags:
    tools_repo: true
  config: [
    label: 'remote'
    ssh:
      host: 'target', username: 'nikita',
      sudo: true
      password: 'secret' # private_key_path: '~/.ssh/id_rsa'
  ]
