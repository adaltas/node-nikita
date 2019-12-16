
module.exports =
  scratch: '/tmp/nikita-test-tools'
  tags:
    cron: false # disable_cron
    posix: true
    tools_dconf: false
    tools_repo: false
    tools_rubygems: false
  ssh: [
    null
    { host: '127.0.0.1', username: process.env.USER }
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
  ]
