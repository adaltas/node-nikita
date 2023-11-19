import os from "node:os"

export default
  tags:
    docker: true
    docker_volume: true
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    # host: 'dind:2375'
  #   # machine: 'nikita'
    docker_host: 'tcp://dind:2375'
    # opts:
    #   host: 'dind:2375'
    # # env:
    # #   DOCKER_HOST:'tcp://dind:2375'
    # compose_env: ['DOCKER_HOST=tcp://dind:2375']
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: os.userInfo().username,
      private_key_path: '~/.ssh/id_ed25519'
  ]
