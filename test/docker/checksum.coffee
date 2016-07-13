# Be aware to specify the machine if docker mahcine is used
# docker.build like, docker.run , docker.rm is used by other docker.command inside
# test amd should not relie on them

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/misc/docker'

describe 'docker checksum', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @

  they 'checksum on existing repository', (ssh, next) ->
    checksum = null
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'mecano/checksum'
    .docker.build
      image: 'mecano/checksum'
      content: "FROM scratch\nCMD ['echo \"hello build from text #{Date.now()}\"']"
    , (err, executed, _checksum, stdout, stderr) ->
      checksum = _checksum.trim() unless err
    .docker.checksum
      image: 'mecano/checksum'
      tag: 'latest'
    , (err, executed, checksum_valid) ->
      checksum_valid.should.startWith "sha256:#{checksum}" unless err
    .docker.rmi
      image: 'mecano/checksum'
    .then next

  they 'checksum on not existing repository', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.checksum
      image: 'mecano/checksum'
      tag: 'latest'
    , (err, executed, checksum) ->
      checksum.should.be.false()
      next()
