
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.compose', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @
  @timeout 90000

  ip = (ssh, machine, callback) ->
    mecano
    .execute
      cmd: """
      export SHELL=/bin/bash
      export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
      bin_boot2docker=$(command -v boot2docker)
      bin_machine=$(command -v docker-machine)
      if [ $bin_machine ];
        then
          if [ \"#{machine}\" = \"--\" ];then exit 5;fi
          eval $(${bin_machine} env #{machine}) && $bin_machine  ip #{machine}
      elif [ $bin_boot2docker ];
        then
          eval $(${bin_boot2docker} shellinit) && $bin_boot2docker ip
      else
        echo '127.0.0.1'
      fi
      """
      , (err, executed, stdout, stderr) ->
        return callback err if err
        ipadress = stdout.trim()
        return callback null, ipadress

  they 'up from content', (ssh, next) ->
    ip ssh, config.docker.machine, (err, ipadress) =>
      mecano
        ssh: ssh
        docker: config.docker
      .docker.rm
        container: 'mecano_docker_compose_up_content'
        force: true
      .docker.compose.up
        content: 
          compose:
            image: 'httpd'
            container_name: 'mecano_docker_compose_up_content'
            ports: ['499:80']
      .execute
        cmd: 'ping dind -c 1'
        code_skipped: [2,68]
      .wait_connect
        if: -> @status -1
        host: 'dind'
        port: 499
      .wait_connect
        unless: -> @status -2
        host: ipadress
        port: 499  
      .docker.rm
        container: 'mecano_docker_compose_up_content'
        force: true
      .then next

  they 'up from file', (ssh, next) ->
    ip ssh, config.docker.machine, (err, ipadress) =>
      mecano
        ssh: ssh
        docker: config.docker
      .docker.rm
        container: 'mecano_docker_compose_up_file'
        force: true
      .file.yaml
        content: 
          compose:
            image: 'httpd'
            container_name: 'mecano_docker_compose_up_file'
            ports: ['499:80']
        target: "#{scratch}/docker_compose_up_file/docker-compose.yml"
      .docker.compose
        target: "#{scratch}/docker_compose_up_file/docker-compose.yml"
      .execute
        cmd: 'ping dind -c 1'
        code_skipped: [2,68]
      .wait_connect
        if: -> @status -1
        host: 'dind'
        port: 499
      .wait_connect
        unless: -> @status -2
        host: ipadress
        port: 499  
      .docker.rm
        container: 'mecano_docker_compose_up_file'
        force: true
      .then next

  they 'up with service naem', (ssh, next) ->
    ip ssh, config.docker.machine, (err, ipadress) =>
      mecano
        ssh: ssh
        docker: config.docker
      .docker.rm
        container: 'mecano_docker_compose_up_service'
        force: true
      .file.yaml
        content:
          compose:
            image: 'httpd'
            container_name: 'mecano_docker_compose_up_service'
            ports: ['499:80']
        target: "#{scratch}/docker_compose_up_file/docker-compose.yml"
      .docker.compose
        service: 'compose'
        target: "#{scratch}/docker_compose_up_file/docker-compose.yml"
      .execute
        cmd: 'ping dind -c 1'
        code_skipped: [2,68]
      .wait_connect
        if: -> @status -1
        host: 'dind'
        port: 499
      .wait_connect
        unless: -> @status -2
        host: ipadress
        port: 499
      .docker.rm
        container: 'mecano_docker_compose_up_service'
        force: true
      .then next
