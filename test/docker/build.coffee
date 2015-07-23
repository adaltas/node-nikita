
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

#needs Internet connection for performing test
describe 'docker build', ->

  scratch = test.scratch @

  they 'Test missing name parameter', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      false_source: 'Dockerfile'
    , (err, executed, stdout, stderr) ->
      err.should.match /^Missing image parameter.*/
    .then (err) -> next()

  they 'Test exclusive parameters', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      image: 'mecano/should_not_exists_1'
      source: "#{__dirname}/Dockerfile"
      write: "FROM scratch \ CMD ['echo \"hello world\"']"
    , (err, executed, stdout, stderr) ->
      err.message.should.match /^Can not build from source and write.*/
    .then (err) -> next()

  they 'from write', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      image: 'mecano/should_not_exists_2'
      write: "FROM scratch\nCMD ['echo \"hello build write\"']"
      machine: 'ryba'
    , (err, executed, stdout, stderr) ->
      executed.should.be.true() unless err
    .docker_rmi
      image: 'mecano/should_not_exists_2'
    .then next

  they 'from source', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      image: 'mecano/should_not_exists_3'
      machine: 'ryba'
      source: "#{__dirname}/Dockerfile"
    , (err, executed, stdout, stderr) ->
      executed.should.be.true()
    .docker_rmi
      image: 'mecano/should_not_exists_3'
    .then next
