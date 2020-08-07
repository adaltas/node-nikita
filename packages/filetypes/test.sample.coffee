
module.exports =
  tags:
    posix: true
  ssh: [
    null
  ,
    ssh: host: '127.0.0.1', username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
  ]
