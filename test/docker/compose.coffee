
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.compose', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @
  @timeout 90000

  they 'up from content', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_docker_compose_up_content'
      force: true
    .docker.compose.up
      content:
        compose:
          image: 'httpd'
          container_name: 'nikita_docker_compose_up_content'
          ports: ['499:80']
    , (err, status) ->
      status.should.be.true() unless err
    .system.execute
      cmd: 'ping dind -c 1'
      code_skipped: [2,68]
    .connection.wait
      if: -> @status -1
      host: 'dind'
      port: 499
    .connection.wait
      unless: -> @status -2
      host: '127.0.0.1'
      port: 499
    .docker.rm
      container: 'nikita_docker_compose_up_content'
      force: true
    .promise()
  
  they 'up from content to file', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_docker_docker_compose_up_content_to_file'
      force: true
    .docker.compose
      content:
        compose:
          image: 'httpd'
          container_name: 'nikita_docker_docker_compose_up_content_to_file'
          ports: ['499:80']
      target: "#{scratch}/docker_compose_up_content_to_file/docker-compose.yml"
    , (err, status) ->
      status.should.be.true() unless err
    .system.execute
      cmd: 'ping dind -c 1'
      code_skipped: [2,68]
    .connection.wait
      if: -> @status -1
      host: 'dind'
      port: 499
    .connection.wait
      unless: -> @status -2
      host: '127.0.0.1'
      port: 499
    .docker.rm
      container: 'nikita_docker_docker_compose_up_content_to_file'
      force: true
    .promise()

  they 'up from file', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_docker_compose_up_file'
      force: true
    .file.yaml
      content:
        compose:
          image: 'httpd'
          container_name: 'nikita_docker_compose_up_file'
          ports: ['499:80']
      target: "#{scratch}/docker_compose_up_file/docker-compose.yml"
    .docker.compose
      target: "#{scratch}/docker_compose_up_file/docker-compose.yml"
    .system.execute
      cmd: 'ping dind -c 1'
      code_skipped: [2,68]
    .connection.wait
      if: -> @status -1
      host: 'dind'
      port: 499
    .connection.wait
      unless: -> @status -2
      host: '127.0.0.1'
      port: 499
    .docker.rm
      container: 'nikita_docker_compose_up_file'
      force: true
    .promise()
  
  they 'up with service name', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_docker_compose_up_service'
      force: true
    .file.yaml
      content:
        compose:
          image: 'httpd'
          container_name: 'nikita_docker_compose_up_service'
          ports: ['499:80']
      target: "#{scratch}/docker_compose_up_file/docker-compose.yml"
    .docker.compose
      service: 'compose'
      target: "#{scratch}/docker_compose_up_file/docker-compose.yml"
    .system.execute
      cmd: 'ping dind -c 1'
      code_skipped: [2,68]
    .connection.wait
      if: -> @status -1
      host: 'dind'
      port: 499
    .connection.wait
      unless: -> @status -2
      host: '127.0.0.1'
      port: 499
    .docker.rm
      container: 'nikita_docker_compose_up_service'
      force: true
    .promise()
  
  they 'status not modified', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_docker_compose_idem'
      force: true
    .file.yaml
      content:
        compose:
          image: 'httpd'
          container_name: 'nikita_docker_compose_idem'
          ports: ['499:80']
      target: "#{scratch}/nikita_docker_compose_idem/docker-compose.yml"
    .docker.compose
      target: "#{scratch}/nikita_docker_compose_idem/docker-compose.yml"
    .connection.wait
      host: 'dind'
      port: 499
    .docker.compose
      target: "#{scratch}/nikita_docker_compose_idem/docker-compose.yml"
    , (err, status) ->
      status.should.be.false() unless err
    .docker.rm
      container: 'nikita_docker_compose_idem'
      force: true
    .promise()
