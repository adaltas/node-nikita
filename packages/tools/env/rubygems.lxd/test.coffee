
module.exports =
  tags:
    posix: false
    tools_dconf: false
    tools_repo: false
    tools_rubygems: true
  scratch: '/home/sshuser/scratch'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'sshuser' }
  ]
