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

clean = (ssh, machine, container, callback) ->
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
          eval $(${bin_machine} env #{machine}) && $bin_docker  rm -f #{container} || true
      elif [ -f $bin_boot2docker ];
        then
          eval $(${bin_boot2docker} shellinit) && $bin_docker rm -f #{container} || true
      else
        $bin_docker rm -f #{container} || true
      fi
      """
    code_skipped: 1
    , (err, executed, stdout, stderr) ->
      return callback err, executed, stdout, stderr

describe 'docker run', ->

  scratch = test.scratch @

  machine = 'dev'

  they 'test simple command', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      service: false
      machine: machine
    , (err, executed, stdout, stderr) ->
      stdout.should.match /^test.*/ unless err
    .then next

  they 'test invalid parameter', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'alpine'
      container: 'mecano_test'
      service: true
      rm: true
      machine: machine
    , (err, executed) ->
      err.message.should.match /^Invalid parameter.*/
    .docker_run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      service: true
      rm: false
      machine: machine
    , (err, executed) ->
      err.message.should.match /^Invalid parameter.*/
    .then (err) -> next null

  they 'test --rm (flag option)', (ssh, next) ->
    clean ssh, machine, 'mecano_test_rm', (err) =>
      return next err if  err
      mecano
        ssh: ssh
      .docker_run
        cmd: "/bin/echo 'test'"
        image: 'alpine'
        container: 'mecano_test_rm'
        service: false
        rm: false
        machine: machine
      , (err, executed, stdout, stderr) ->
        stdout.should.match /^test.*/ unless err
        clean ssh, machine, 'mecano_test_rm', (err) -> next(err)

  they 'test unique option from array option', (ssh, next) ->
    clean ssh, machine, 'mecano_test_unique', (err) =>
      return next err if  err
      ip ssh, machine, (err, ipadress) =>
        return next err if  err
        mecano
          ssh: ssh
        .docker_run
          image: 'httpd'
          port: '499:80'
          machine: machine
          container: 'mecano_test_unique'
        .wait_connect
          port: 499
          host: ipadress
        , (err) ->
          clean ssh, machine, 'mecano_test_unique', (err) -> next(err)

  they 'test array options', (ssh, next) ->
    clean ssh, machine, 'mecano_test_array', (err) =>
      return next err if  err
      ip ssh, machine, (err, ipadress) =>
        return next err if  err
        mecano
          ssh: ssh
        .docker_run
          image: 'httpd'
          port: [ '500:80', '501:81' ]
          machine: machine
          container: 'mecano_test_array'
        .wait_connect
          host: ipadress
          port: 500
        , (err) ->
          clean ssh, machine, 'mecano_test_array', (err) => next(err)

  they 'test status not modified', (ssh, next) ->
    clean ssh, machine, 'mecano_test', (err) =>
      return next err if  err
      mecano
        ssh: ssh
      .docker_run
        cmd: 'echo test'
        image: 'alpine'
        container: 'mecano_test'
        machine: machine
      .docker_run
        cmd: "echo test"
        image: 'alpine'
        container: 'mecano_test'
        machine: machine
      , (err, executed, out, serr) ->
        executed.should.be.false()
        clean ssh, machine, 'mecano_test', (err) =>
          next(err)

  they 'test force running ', (ssh, next) ->
    clean ssh, machine, 'mecano_test', (err, executed, stdout, stderr) ->
      return next err if  err
      mecano
        ssh: ssh
      .docker_run
        image: 'alpine'
        container: 'mecano_test'
        cmd: "/bin/echo 'test'"
        machine: machine
      .docker_run
        cmd: "/bin/echo 'test'"
        image: 'alpine'
        container: 'mecano_test'
        machine: machine
        force: true
      , (err, executed, stdout, stderr) ->
        executed.should.be.true()
        clean ssh, machine, 'mecano_test', (err) => next(err)
