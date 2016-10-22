
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.compose', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @
  @timeout 90000

  they 'up from content', (ssh, next) ->
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
    , (err, status) ->
      return next err if err
      status.should.be.true()
    .execute
      cmd: 'ping dind -c 1'
      code_skipped: [2,68]
    .wait_connect
      if: -> @status -1
      host: 'dind'
      port: 499
    .wait_connect
      unless: -> @status -2
      host: '127.0.0.1'
      port: 499
    .docker.rm
      container: 'mecano_docker_compose_up_content'
      force: true
    .then next
  
  they 'up from content to file', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'mecano_docker_docker_compose_up_content_to_file'
      force: true
    .docker.compose
      content:
        compose:
          image: 'httpd'
          container_name: 'mecano_docker_docker_compose_up_content_to_file'
          ports: ['499:80']
      target: "#{scratch}/docker_compose_up_content_to_file/docker-compose.yml"
    , (err, status) ->
      return next err if err
      status.should.be.true()
    .execute
      cmd: 'ping dind -c 1'
      code_skipped: [2,68]
    .wait_connect
      if: -> @status -1
      host: 'dind'
      port: 499
    .wait_connect
      unless: -> @status -2
      host: '127.0.0.1'
      port: 499
    .docker.rm
      container: 'mecano_docker_docker_compose_up_content_to_file'
      force: true
    .then next

  they 'up from file', (ssh, next) ->
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
      host: '127.0.0.1'
      port: 499
    .docker.rm
      container: 'mecano_docker_compose_up_file'
      force: true
    .then next
  
  they 'up with service name', (ssh, next) ->
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
      host: '127.0.0.1'
      port: 499
    .docker.rm
      container: 'mecano_docker_compose_up_service'
      force: true
    .then next
  
  they 'status not modified', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
      debug: true
    .docker.rm
      container: 'mecano_docker_compose_idem'
      force: true
    .file.yaml
      content: 
        compose:
          image: 'httpd'
          container_name: 'mecano_docker_compose_idem'
          ports: ['499:80']
      target: "#{scratch}/mecano_docker_compose_idem/docker-compose.yml"
    .docker.compose
      target: "#{scratch}/mecano_docker_compose_idem/docker-compose.yml"
    .execute
      cmd: 'ping dind -c 1'
      code_skipped: [2,68]
    .wait_connect
      if: -> @status -1
      host: 'dind'
      port: 499
    .wait_connect
      unless: -> @status -2
      host: '127.0.0.1'
      port: 499
    .docker.compose
      target: "#{scratch}/mecano_docker_compose_idem/docker-compose.yml"
    , (err, status) ->
      return next err if err
      status.should.be.false()
    .docker.rm
      container: 'mecano_docker_compose_idem'
      force: true
    .then next
