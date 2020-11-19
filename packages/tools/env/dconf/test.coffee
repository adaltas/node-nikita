
module.exports =
  tags:
    posix: false
    tools_dconf: true
    tools_repo: false
    tools_rubygems: false
  ssh: [
    null
    { ssh: host: 'localhost', username: 'sshuser' }
  ]
