# Be aware to specify the machine if docker mahcine is used
# Some other docker test uses docker_run
# as a conseauence docker_run should not docker an other command from docker family
# For this purpos ip, and clean are used

stream = require 'stream'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/misc/docker'

ip = (ssh, machine, callback) ->
  mecano
  .execute
    cmd: """
      export SHELL=/bin/bash
      export PATH=/opt/local/bin/:/opt/local/sbin/:/usr/local/bin/:/usr/local/sbin/:$PATH
      bin_boot2docker=$(command -v boot2docker)
      bin_docker=$(command -v docker)
      bin_machine=$(command -v docker-machine)
      if [ -f $bin_machine ];
        if [ \"#{machine}\" = \"--\" ];then exit 5;fi
        then
          eval $(${bin_machine} env #{machine}) && $bin_machine  ip #{machine}
      elif [ -f $bin_boot2docker ];
        then
          eval $(${bin_boot2docker} shellinit) && $bin_boot2docker ip
      else
        echo '127.0.0.1'
      fi
      """
    , (err, executed, stdout, stderr) ->
      return callback err if err
      ipadress = stdout.trim()
      return callback null, ipadress

describe 'docker run', ->

  config = test.config()
  return if config.docker.disable
  scratch = test.scratch @

  they 'simple command', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      service: false
      machine: config.docker.machine
    , (err, executed, stdout, stderr) ->
      stdout.should.match /^test.*/ unless err
    .then next

  they 'invalid parameter', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      machine: config.docker.machine
      image: 'alpine'
      name: 'mecano_test'
      service: true
      rm: true
    , (err, executed) ->
      err.message.should.match /^Invalid parameter.*/
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      service: true
      rm: false
      machine: config.docker.machine
    , (err, executed) ->
      err.message.should.match /^Invalid parameter.*/
    .then (err) -> next null

  they '--rm (flag option)', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      machine: config.docker.machine
      force: true
      container: 'mecano_test_rm'
    .docker_run
      machine: config.docker.machine
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      name: 'mecano_test_rm'
      service: false
      rm: false
      , (err, executed, stdout, stderr) ->
        return err if err
        stdout.should.match /^test.*/ unless err
        mecano
          ssh: ssh
        .docker_rm
          machine: config.docker.machine
          force: true
          container: 'mecano_test_rm'
        .then next

  they 'unique option from array option', (ssh, next) ->
    ip ssh, config.docker.machine, (err, ipadress) =>
      return next err if  err
      @timeout 60000
      mecano
        ssh: ssh
      .docker_rm
        machine: config.docker.machine
        container: 'mecano_test_unique'
        force: true
      .docker_run
        machine: config.docker.machine
        image: 'httpd'
        port: '499:80'
        machine: config.docker.machine
        name: 'mecano_test_unique'
        service: true
        rm: false
      .wait_connect
        port: 499
        host: ipadress
      .docker_rm
        force: true
        machine: config.docker.machine
        container: 'mecano_test_unique'
      .then next

  they 'array options', (ssh, next) ->
    ip ssh, config.docker.machine, (err, ipadress) =>
      return next err if  err
      @timeout 60000
      mecano
        ssh: ssh
      .docker_rm
        force: true
        machine: config.docker.machine
        container: 'mecano_test_array'
      .docker_run
        image: 'httpd'
        port: [ '500:80', '501:81' ]
        machine: config.docker.machine
        name: 'mecano_test_array'
        service: true
        rm: false
      .wait_connect
        host: ipadress
        port: 500
      .docker_rm
        force: true
        container: 'mecano_test_array'
        machine: config.docker.machine
      .then next

  they 'existing container', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      machine: config.docker.machine
      force: true
      container: 'mecano_test'
    .docker_run
      cmd: 'echo test'
      image: 'alpine'
      name: 'mecano_test'
      machine: config.docker.machine
      rm: false
    .docker_run
      cmd: "echo test"
      image: 'alpine'
      name: 'mecano_test'
      machine: config.docker.machine
      rm: false
    , (err, executed, out, serr) ->
      err.message.should.match /^Use force option if you want to get a new running instance.*/ unless err
      mecano
        ssh: ssh
      .docker_rm
        machine: config.docker.machine
        force: true
        container: 'mecano_test'
      .then next

  # they 'status not modified', (ssh, next) ->
  #   @timeout 30000
  #   mecano
  #     ssh: ssh
  #   .docker_rm
  #     machine: config.docker.machine
  #     force: true
  #     container: 'mecano_test'
  #   .docker_run
  #     cmd: 'echo test'
  #     image: 'alpine'
  #     name: 'mecano_test'
  #     machine: config.docker.machine
  #     rm: false
  #   .docker_run
  #     cmd: "echo test"
  #     image: 'alpine'
  #     name: 'mecano_test'
  #     machine: config.docker.machine
  #     rm: false
  #   , (err, executed, out, serr) ->
  #     executed.should.be.false()
  #     mecano
  #       ssh: ssh
  #     .docker_rm
  #       machine: config.docker.machine
  #       force: true
  #       container: 'mecano_test'
  #     .then next

  they 'force running ', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rm
      container: 'mecano_test'
      machine: config.docker.machine
    .docker_run
      image: 'alpine'
      name: 'mecano_test'
      cmd: "/bin/echo 'test'"
      machine: config.docker.machine
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      name: 'mecano_test'
      machine: config.docker.machine
      force: true
    , (err, executed, stdout, stderr) ->
      return err if err
      executed.should.be.true()
      mecano
        ssh: ssh
      .docker_rm
        container: 'mecano_test'
        machine: config.docker.machine
      , (err) -> next(err)
