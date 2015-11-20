# Be aware to specify the machine if docker mahcine is used
# docker_build like, docker_run , docker_rm is used by other docker_command inside
# test amd should not relie on them

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/misc/docker'

clean = (ssh, machine, image, callback) ->
  docker.exec " rmi -f #{image} || true" , {  ssh: ssh, machine: machine }, null
  , (err, executed, stdout, stderr) -> callback err, executed, stdout, stderr

describe 'docker checksum', ->

  scratch = test.scratch @
  machine = 'dev'

  they 'checksum on existing image', (ssh, next) ->
    clean ssh, machine, 'mecano/checksum', (err) ->
      mecano
        ssh: ssh
      .docker_build
        image: 'mecano/checksum'
        content: "FROM scratch\nCMD ['echo \"hello build from text #{Date.now()}\"']"
        machine: machine
      , (err, executed, stdout, stderr, checksum) ->
        return err if err
        mecano
          ssh: ssh
        .docker_checksum
          image: 'mecano/checksum'
          machine: machine
        , (err, executed, stdout, stderr, checksum_valid) ->
          return err if err
          checksum_valid.should.eql(checksum)
          clean ssh, machine, 'mecano/checksum', (err) -> next(err)

  they 'checksum on not existing image', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_checksum
      image: 'mecano/checksum'
      machine: machine
    , (err, executed, stdout, stderr, checksum) ->
      checksum.should.be.false()
      next()
