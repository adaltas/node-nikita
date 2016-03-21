# Be aware to specify the machine if docker mahcine is used
# docker_build like, docker_run , docker_rm is used by other docker_command inside
# test amd should not relie on them

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/misc/docker'

# clean = (ssh, machine, image, callback) ->
# clean = (options, callback) ->
#   @execute docker.wrap options, " rmi -f #{options.image} || true"

describe 'docker build', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @
  @timeout 60000

  they 'fail with missing image parameter', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker_build
      false_source: 'Dockerfile'
    .then (err) ->
      return next Error 'Expect error' unless err
      err.message.should.eql 'Required option "image"'
    .then next

  they 'fail with exclusive parameters', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker_build
      image: 'mecano/should_not_exists_1'
      file: "#{__dirname}/Dockerfile"
      content: "FROM scratch \ CMD ['echo \"hello world\"']"
    .then (err) ->
      err.message.should.eql 'Can not build from Dockerfile and content'
    .then next

  they 'from text', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker_rmi
      image: 'mecano/should_exists_2'
    .docker_build
      image: 'mecano/should_exists_2'
      content: """
      FROM scratch
      CMD echo hello
      """
    , (err, executed, stdout, stderr) ->
      executed.should.be.true() unless err
      stderr.should.containEql 'Step 2 : CMD echo hello' unless err
    .docker_rmi
      image: 'mecano/should_exists_2'
    .then next

  they 'from cwd',  (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker_rmi
      image: 'mecano/should_exists_3'
    .write
      destination: "#{scratch}/Dockerfile"
      content: """
      FROM scratch
      CMD echo hello
      """
    .docker_build
      image: 'mecano/should_exists_3'
      cwd: scratch
    , (err, executed, stdout, stderr) ->
      executed.should.be.true() unless err
    .docker_rmi
      image: 'mecano/should_exists_3'
    .then next

  they 'from Dockerfile (exist)', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker_rmi
      image: 'mecano/should_exists_3'
    .write
      content: "FROM scratch\nCMD ['echo \"hello build from Dockerfile #{Date.now()}\"']"
      destination: "#{scratch}/mecano_Dockerfile"
    .docker_build
      image: 'mecano/should_exists_4'
      file: "#{scratch}/mecano_Dockerfile"
    , (err, executed) ->
      executed.should.be.true() unless err
    .docker_rmi
      image: 'mecano/should_exists_3'
    .then next

  they 'from Dockerfile (not exist)', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker_build
      image: 'mecano/should_not_exists_4'
      file: 'unexisting/file'
      relax: true
    , (err, executed, stdout, stderr) ->
      err.code.should.eql 'ENOENT'
    .then next

  they 'status not modified', (ssh, next) ->
    status_true = status_false = null
    mecano
      ssh: ssh
      docker: config.docker
    .docker_rmi
      image: 'mecano/should_exists_5'
    .write
      destination: "#{scratch}/mecano_Dockerfile"
      content: """
      FROM scratch
      CMD echo hello
      """
    .docker_build
      image: 'mecano/should_exists_5'
      file: "#{scratch}/mecano_Dockerfile"
      log: (msg) -> status_true = msg
    , (err, executed) ->
      executed.should.be.true()
    .docker_build
      image: 'mecano/should_exists_5'
      file: "#{scratch}/mecano_Dockerfile"
      log: (msg) -> status_false = msg
    , (err, executed) ->
      executed.should.be.false()
    .docker_rmi
      image: 'mecano/should_exists_5'
    .call ->
      status_true.message.should.match /^New image id/
      status_false.message.should.match /^Identical image id/
    .then next
