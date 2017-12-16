# Be aware to specify the machine if docker mahcine is used
# docker.build like, docker.run , docker.rm is used by other docker.command inside
# test amd should not relie on them

should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/misc/docker'

describe 'docker.build', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @
  @timeout 60000

  they 'fail with missing image parameter', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.build
      false_source: 'Dockerfile'
    .next (err) ->
      return next Error 'Expect error' unless err
      err.message.should.eql 'Required option "image"'
    .promise()

  they 'fail with exclusive parameters', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.build
      image: 'nikita/should_not_exists_1'
      file: "#{__dirname}/Dockerfile"
      content: "FROM scratch \ CMD ['echo \"hello world\"']"
    .next (err) ->
      err.message.should.eql 'Can not build from Dockerfile and content'
    .promise()

  they 'from text', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'nikita/should_exists_2'
    .docker.build
      image: 'nikita/should_exists_2'
      content: """
      FROM scratch
      CMD echo hello
      """
    , (err, executed, stdout, stderr) ->
      executed.should.be.true() unless err
      stderr.should.containEql 'Step 2 : CMD echo hello' unless err
    .docker.rmi
      image: 'nikita/should_exists_2'
    .promise()

  they 'from cwd',  (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'nikita/should_exists_3'
    .file
      target: "#{scratch}/Dockerfile"
      content: """
      FROM scratch
      CMD echo hello
      """
    .docker.build
      image: 'nikita/should_exists_3'
      cwd: scratch
    , (err, executed, stdout, stderr) ->
      executed.should.be.true() unless err
    .docker.rmi
      image: 'nikita/should_exists_3'
    .promise()

  they 'from Dockerfile (exist)', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'nikita/should_exists_3'
    .file
      content: "FROM scratch\nCMD ['echo \"hello build from Dockerfile #{Date.now()}\"']"
      target: "#{scratch}/nikita_Dockerfile"
    .docker.build
      image: 'nikita/should_exists_4'
      file: "#{scratch}/nikita_Dockerfile"
    , (err, executed) ->
      executed.should.be.true() unless err
    .docker.rmi
      image: 'nikita/should_exists_3'
    .promise()

  they 'from Dockerfile (not exist)', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.build
      image: 'nikita/should_not_exists_4'
      file: 'unexisting/file'
      relax: true
    , (err, executed, stdout, stderr) ->
      err.code.should.eql 'ENOENT'
    .promise()

  they 'status not modified', (ssh) ->
    status_true = status_false = null
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rmi
      image: 'nikita/should_exists_5'
    .file
      target: "#{scratch}/nikita_Dockerfile"
      content: """
      FROM scratch
      CMD echo hello
      """
    .docker.build
      image: 'nikita/should_exists_5'
      file: "#{scratch}/nikita_Dockerfile"
      log: (msg) -> status_true = msg
    , (err, executed) ->
      executed.should.be.true()
    .docker.build
      image: 'nikita/should_exists_5'
      file: "#{scratch}/nikita_Dockerfile"
      log: (msg) -> status_false = msg
    , (err, executed) ->
      executed.should.be.false()
    .docker.rmi
      image: 'nikita/should_exists_5'
    .call ->
      status_true.message.should.match /^New image id/
      status_false.message.should.match /^Identical image id/
    .promise()
