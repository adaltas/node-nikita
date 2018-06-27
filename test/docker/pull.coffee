#Be aware to specify the machine if docker mahcine is used

nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker.pull', ->

  config = test.config()
  return if config.disable_docker

  they 'No Image', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'alpine'
    .docker.pull
      tag: 'alpine'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'Status Not Modified', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'alpine'
    .docker.pull
      tag: 'alpine'
    .docker.pull
      tag: 'alpine'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
