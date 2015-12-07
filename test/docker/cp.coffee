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


  they 'copy simple file (with temp_dir)', (ssh, next) ->
    @timeout 20000
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_extract'
      machine: machine
    .docker_run
      name: 'mecano_extract'
      image: 'alpine'
      machine: machine
      cmd: "ls -l  #{source}"
    .docker_cp
      container: 'mecano_extract'
      machine: machine
      path: source
      host_dir: destination
    .then (err, executed, stdout) =>
        executed.should.be.true() unless err
        fs.stat ssh, "#{destination}/default.script", (err, stat) ->
          next(err) if err
          should.exist(stat)
          mecano.docker_rm
            container: 'mecano_extract'
            machine: machine
          .then (err, executed, stdout) => next(err)

  they 'copy simple file (no temp_dir)', (ssh, next) ->
    @timeout 20000
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_extract'
      machine: machine
    .docker_run
      name: 'mecano_extract'
      image: 'alpine'
      machine: machine
      cmd: "ls -l  #{source}"
    .docker_cp
      container: 'mecano_extract'
      machine: machine
      path: source
      host_dir: destination
    .then (err, executed, stdout) =>
        executed.should.be.true() unless err
        fs.stat ssh, "#{destination}/default.script", (err, stat) ->
          next(err) if err
          should.exist(stat)
          mecano.docker_rm
            container: 'mecano_extract'
            machine: machine
          .then (err, executed, stdout) => next(err)

  they 'target not exist', (ssh, next) ->
    @timeout 20000
    mecano
      ssh: ssh
    .docker_cp
      container: 'mecano_extract'
      machine: machine
      path: source
      host_dir: 'not_existing_target'
    , (err, executed, stdout) =>
        executed.should.be.false()
        should.exist(err)
        next()

  they 'target not a directory', (ssh, next) ->
    mecano
      ssh: ssh
    .write
      content: 'I am a line in a file'
      destination: "#{scratch}/a_file"
    .docker_cp
      container: 'mecano_extract'
      machine: machine
      path: source
      host_dir: "#{scratch}/a_file"
    , (err, executed, stdout) =>
        executed.should.be.false()
        next(err)

  they 'copy unless file exists (with temp_dir)', (ssh, next) ->
    @timeout 20000
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_extract'
      machine: machine
    .docker_run
      name: 'mecano_extract'
      image: 'alpine'
      machine: machine
      cmd: "ls -l  #{source}"
    .docker_cp
      path: source
      host_dir: destination
      machine: machine
      container: 'mecano_extract'
    .docker_cp
      path: source
      host_dir: destination
      machine: machine
      container: 'mecano_extract'
    , (err, executed, stdout, stderr) ->
      executed.should.be.false() unless err
      next(err)

  they 'copy unless file exists (no temp_dir)', (ssh, next) ->
    @timeout 20000
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_extract'
      machine: machine
    .docker_run
      name: 'mecano_extract'
      image: 'alpine'
      machine: machine
      cmd: "ls -l  #{source}"
    .docker_cp
      path: source
      host_dir: destination
      machine: machine
      container: 'mecano_extract'
    .docker_cp
      path: source
      host_dir: destination
      machine: machine
      container: 'mecano_extract'
      temp_dir: false
    , (err, executed, stdout, stderr) ->
      executed.should.be.true() unless err
      next(err)
