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

describe 'docker build', ->

  scratch = test.scratch @
  machine = 'dev'

  they 'Test missing image parameter', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      false_source: 'Dockerfile'
    .then (err) ->
      return next Error 'Expect error' unless err
      err.message.should.eql 'Missing tag parameter'
    .then next


  they 'Test exclusive parameters', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      tag: 'mecano/should_not_exists_1'
      path: "#{__dirname}/Dockerfile"
      content: "FROM scratch \ CMD ['echo \"hello world\"']"
    .then (err) ->
      return next Error 'Expect error' unless err
      err.message.should.eql 'Can not build from Dockerfile and content'
    .then next


  they 'from text', (ssh, next) ->
    clean ssh, machine, 'mecano/should_exists_2', (err) ->
      mecano
        ssh: ssh
      .docker_build
        tag: 'mecano/should_exists_2'
        content: "FROM scratch\nCMD ['echo \"hello build from text #{Date.now()}\"']"
        machine: machine
      , (err, executed, stdout, stderr) ->
        executed.should.be.true() unless err
        clean ssh, machine, 'mecano/should_exists_2', (err) -> next(err)

  they 'from cwd',  (ssh, next) ->
    clean ssh, machine, 'mecano/should_exists_3', (err) =>
      @timeout 60000
      mecano
        ssh: ssh
      .write
        content: "FROM scratch\nCMD ['echo \"hello build from cwd #{Date.now()} \"']"
        destination: "#{scratch}/Dockerfile"
      .docker_build
        tag: 'mecano/should_exists_3'
        machine: machine
        cwd: scratch
      , (err, executed, stdout, stderr) ->
        executed.should.be.true() unless err
        clean ssh, machine, 'mecano/should_exists_3'
        , (err) ->
            mecano
              ssh: ssh
            .remove
              destination: "#{scratch}/mecano_Dockerfile"
            .then next()

  they 'from Dockerfile (exist)', (ssh, next) ->
    clean ssh, machine, 'mecano/should_exists_4', (err) ->
      mecano
        ssh: ssh
        timeout: -1
      .write
        content: "FROM scratch\nCMD ['echo \"hello build from Dockerfile #{Date.now()}\"']"
        destination: "#{scratch}/mecano_Dockerfile"
      .docker_build
        tag: 'mecano/should_exists_4'
        path: "#{scratch}/mecano_Dockerfile"
        machine: machine
      .then (err, executed, stdout, stderr) ->
        executed.should.be.true() unless err
        clean ssh, machine, 'mecano/should_exists_4'
        , (err) ->
            mecano
              ssh: ssh
            .remove
              destination: "#{scratch}/mecano_Dockerfile"
            .then next()

  they 'from Dockerfile (not exist)', (ssh, next) ->
    clean ssh, machine, 'mecano/should_not_exists_4', (err) ->
      mecano
        ssh: ssh
      .docker_build
        tag: 'mecano/should_not_exists_4'
        path: 'unexisting/file'
        machine: machine
      , (err, executed, stdout, stderr) ->
        executed.should.be.false()
        next()

  they 'status not modified (from stdin text)', (ssh, next) ->
    clean ssh, machine, 'mecano/should_not_exists_4', (err) ->
      mecano
        ssh: ssh
      .write
        content: "FROM scratch\nCMD ['echo \"hello build from Dockerfile #{Date.now()}\"']"
        destination: "#{scratch}/mecano_Dockerfile"
      .docker_build
        tag: 'mecano/should_not_exists_4'
        path: "#{scratch}/mecano_Dockerfile"
        machine: machine
      .docker_build
        tag: 'mecano/should_not_exists_4'
        path: "#{scratch}/mecano_Dockerfile"
        machine: machine
      , (err, executed, stdout, stderr) ->
        executed.should.be.false()
        clean ssh, machine, 'mecano/should_not_exists_4', (err) -> next()
