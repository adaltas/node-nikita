
module.exports =
  tags:
    posix: false
    tools_dconf: false
    tools_repo: true
    tools_rubygems: false
  ssh: [
    null
    { ssh: host: 'localhost', username: 'sshuser' }
  ]
