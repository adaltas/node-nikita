
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'docker build', ->

  scratch = test.scratch @

  they 'Test missing image parameter', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      false_source: 'Dockerfile'
    .then (err) ->
      return next Error 'Expect error' unless err
      err.message.should.eql 'Missing image parameter'
    .then next

  they 'Test exclusive parameters', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      image: 'mecano/should_not_exists_1'
      dockerfile: "#{__dirname}/Dockerfile"
      content: "FROM scratch \ CMD ['echo \"hello world\"']"
    .then (err) ->
      return next Error 'Expect error' unless err
      err.message.should.eql 'Can not build from Dockerfile and content'
    .then next

  they 'from text', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      image: 'mecano/should_not_exists_2'
      content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
      machine: 'ryba'
    , (err, executed, stdout, stderr) ->
      executed.should.be.true()
    .docker_rmi
      image: 'mecano/should_not_exists_2'
    .then next

  they 'from cwd', (ssh, next) ->
    mecano
      ssh: ssh
    .write
      content: "FROM scratch\nCMD ['echo \"hello build from cwd\"']"
      destination: "#{scratch}/Dockerfile"
    .docker_build
      image: 'mecano/should_not_exists_3'
      machine: 'ryba'
      cwd: scratch
    , (err, executed, stdout, stderr) ->
      executed.should.be.true()
    .docker_rmi
      image: 'mecano/should_not_exists_3'
    .remove
      destination: "#{scratch}/Dockerfile"
    .then next

  they 'from Dockerfile', (ssh, next) ->
    mecano
      ssh: ssh
    .write
      content: "FROM scratch\nCMD ['echo \"hello build from Dockerfile\"']"
      destination: "#{scratch}/mecano_Dockerfile"
    .docker_build
      image: 'mecano/should_not_exists_4'
      dockerfile: "#{scratch}/mecano_Dockerfile"
      machine: 'ryba'
    , (err, executed, stdout, stderr) ->
      executed.should.be.true()
    .docker_rmi
      image: 'mecano/should_not_exists_4'
    .remove
      destination: "#{scratch}/mecano_Dockerfile"
    .then next
