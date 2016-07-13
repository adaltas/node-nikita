# Be aware to specify the machine if docker mahcine is used
# Some other docker test uses docker.run
# as a conseauence docker.run should not docker an other command from docker family
# For this purpos ip, and clean are used

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
    bin_machine=$(command -v docker-machine)
    if [ $bin_machine ];
      then
        if [ \"#{machine}\" = \"--\" ];then exit 5;fi
        eval $(${bin_machine} env #{machine}) && $bin_machine  ip #{machine}
    elif [ $bin_boot2docker ];
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
  return if config.disable_docker
  scratch = test.scratch @

  they 'simple command', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
    , (err, status, stdout, stderr) ->
      status.should.be.true()
      stdout.should.match /^test.*/ unless err
    .then next
  
  they '--rm (flag option)', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'mecano_test_rm'
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      name: 'mecano_test_rm'
      rm: false
      , (err, executed, stdout, stderr) ->
        return err if err
        stdout.should.match /^test.*/ unless err
        mecano
          ssh: ssh
        .docker.rm
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
        machine: config.docker.machine
      .docker.rm
        container: 'mecano_test_unique'
        force: true
      .docker.run
        image: 'httpd'
        port: '499:80'
        machine: config.docker.machine
        name: 'mecano_test_unique'
        detach: true
        rm: false
      .wait_connect
        port: 499
        host: ipadress
      .docker.rm
        force: true
        container: 'mecano_test_unique'
      .then next

  they 'array options', (ssh, next) ->
    ip ssh, config.docker.machine, (err, ipadress) =>
      return next err if  err
      @timeout 60000
      mecano
        ssh: ssh
        machine: config.docker.machine
      .docker.rm
        force: true
        container: 'mecano_test_array'
      .docker.run
        image: 'httpd'
        port: [ '500:80', '501:81' ]
        name: 'mecano_test_array'
        detach: true
        rm: false
      .wait_connect
        host: ipadress
        port: 500
      .docker.rm
        force: true
        container: 'mecano_test_array'
      .then next

  they 'existing container', (ssh, next) ->
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'mecano_test'
    .docker.run
      cmd: 'echo test'
      image: 'alpine'
      name: 'mecano_test'
      rm: false
    .docker.run
      cmd: "echo test"
      image: 'alpine'
      name: 'mecano_test'
      rm: false
    , (err, runned) ->
      runned.should.be.false()
    .docker.rm
      force: true
      container: 'mecano_test'
    .then next

  they 'status not modified', (ssh, next) ->
    @timeout 30000
    mecano
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'mecano_test'
    .docker.run
      cmd: 'echo test'
      image: 'alpine'
      name: 'mecano_test'
      rm: false
    .docker.run
      cmd: 'echo test'
      image: 'alpine'
      name: 'mecano_test'
      rm: false
    , (err, executed, out, serr) ->
      executed.should.be.false()
      mecano
        ssh: ssh
        machine: config.docker.machine
      .docker.rm
        force: true
        container: 'mecano_test'
      .then next
