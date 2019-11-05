
module.exports =
  tags:
    posix: false
    tools_dconf: true
    tools_repo: false
    tools_rubygems: false
  scratch: '/home/sshuser/scratch'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'sshuser' }
  ]
