#Be aware to specify the machine if docker mahcine is used

should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'


describe 'docker cp', ->

  scratch = test.scratch @
  destination = "#{scratch}"
  source = '/usr/share/udhcpc/default.script'
  machine = 'dev'


  they 'copy simple file', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_extract'
      machine: machine
    .docker_run
      container: 'mecano_extract'
      image: 'alpine'
      machine: machine
      cmd: "ls -l  #{source}"
    .docker_cp
      container: 'mecano_extract'
      machine: machine
      source: source
      destination: destination
    .then (err, executed, stdout) =>
        executed.should.be.true() unless err
        fs.stat ssh, "#{destination}/default.script", (err, stat) ->
          next(err) if err
          should.exist(stat)
          mecano.docker_rm
            container: 'mecano_extract'
            machine: machine
          .then (err, executed, stdout) => next(err)

  they 'copy unless file exists', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_extract'
      machine: machine
    .docker_run
      container: 'mecano_extract'
      image: 'alpine'
      machine: machine
      cmd: "ls -l  #{source}"
    .docker_cp
      source: source
      destination: destination
      machine: machine
      container: 'mecano_extract'
    .docker_cp
      source: source
      destination: destination
      machine: machine
      container: 'mecano_extract'
    , (err, executed, stdout, stderr) ->
      executed.should.be.false() unless err
      next(err)
