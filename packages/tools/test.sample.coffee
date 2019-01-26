
module.exports =
  tags:
    posix: true
    tools_repo: false
    tools_rubygems: false
  ssh:
    host: '127.0.0.1'
    username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
