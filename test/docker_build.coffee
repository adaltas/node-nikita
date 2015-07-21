
{EventEmitter} = require 'events'
should = require 'should'
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'
expect = require 'expect'
docker = require "../src/misc/docker"

#needs Internet connection for performing test
describe 'docker_build', ->

  scratch = test.scratch @

  they 'Test missing name parameter', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      dockerfile_source: 'Dockerfile'
    , (err, executed, stdout, stderr) ->
      err.message.should.match /^Missing build name.*/
    .then (err) -> next null

  they 'Test missing dockerfile_* parameters', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      name: 'mecano/test'
    , (err, executed, stdout, stderr) ->
      err.message.should.match /^dockerfile_source and dockerfile_write not specified.*/
    .then (err) -> next null

  they 'Test exclusive parameters ', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      name: 'mecano/test'
      source: "#{__dirname}/Dockerfile"
      write: "FROM scratch \ CMD ['echo \"hello world\"']"
    , (err, executed, stdout, stderr) ->
      err.message.should.match /^can not build from source and write.*/
    .then (err) -> next null

  # they 'Test build from write', (ssh, next) ->
  #   @timeout 100000
  #   mecano
  #     ssh: ssh
  #   .docker_build
  #     name: 'mecano/test'
  #     write: "FROM scratch"
  #     machine: 'ryba'
  #   , (err, executed, stdout, stderr) ->
  #     executed.should.be.true()() unless err
  #   .then (err) -> next null

  they 'Test build from source', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_build
      name: 'mecano/test'
      machine: 'ryba'
      source: "#{__dirname}/Dockerfile"
    , (err, executed, stdout, stderr) ->
      executed.should.be.true()() unless err
    .then (err) -> next null



