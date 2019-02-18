
nikita = require '@nikitajs/core'
{tags, ssh, docker} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.docker

describe 'docker.service', ->

  they 'simple service', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      force: true
      container: 'nikita_test_unique'
    .docker.service
      image: 'httpd'
      name: 'nikita_test_unique'
      port: '499:80'
    # .wait_connect
    #   port: 499
    #   host: ipadress of docker, docker-machine...
    .docker.rm
      force: true
      container: 'nikita_test_unique'
    .promise()

  they 'invalid options', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      container: 'nikita_test'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      relax: true
    , (err) ->
      err.message.should.eql 'Missing container name'
    .docker.service
      name: 'toto'
      port: '499:80'
      relax: true
    , (err) ->
      err.message.should.eql 'Missing image'
    .docker.rm
      force: true
      container: 'nikita_test'
    .promise()

  they 'status not modified', ({ssh}) ->
    nikita
      ssh: ssh
      docker: docker
    .docker.rm
      force: true
      container: 'nikita_test'
    .docker.service
      name: 'nikita_test'
      image: 'httpd'
      port: '499:80'
    .docker.service
      name: 'nikita_test'
      image: 'httpd'
      port: '499:80'
    , (err, {status}) ->
      status.should.be.false()
    .docker.rm
      force: true
      container: 'nikita_test'
    .promise()
