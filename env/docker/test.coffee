
module.exports =
  tags:
    docker: true
    docker_volume: true
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  ssh:
    host: 'localhost'
    username: 'root'
