
module.exports =
  tags:
    posix: false
    tools_dconf: false
    tools_repo: false
    tools_rubygems: false
    tools_npm: true
  ssh: [
    null
    { ssh: host: 'localhost', username: 'sshuser' }
  ]
