
module.exports =
  scratch: '/tmp/nikita-test-docker'
  tags:
    docker: false # disable_docker
    docker_volume: false
  docker: # eg `docker-machine create --driver virtualbox nikita`
    machine: 'nikita'
  ssh: [
    null
  ,
    ssh: host: '127.0.0.1', username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
  ]
