# Be aware to specify the machine if docker mahcine is used
# Some other docker test uses docker.run
# as a conseauence docker.run should not docker an other command from docker family
# For this purpos ip, and clean are used

nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/misc/docker'

ip = (ssh, machine, callback) ->
  nikita
  .system.execute
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
    , (err, {stdout}) ->
      return callback err if err
      ipadress = stdout.trim()
      return callback null, ipadress

describe 'docker.run', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @

  they 'simple command', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
    , (err, {status, stdout}) ->
      status.should.be.true()
      stdout.should.match /^test.*/ unless err
    .promise()
  
  they '--rm (flag option)', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'nikita_test_rm'
    .docker.run
      cmd: "/bin/echo 'test'"
      image: 'alpine'
      name: 'nikita_test_rm'
      rm: false
    , (err, {stdout}) ->
      stdout.should.match /^test.*/ unless err
    .docker.rm
      force: true
      container: 'nikita_test_rm'
    .promise()

  they 'unique option from array option', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test_unique'
      force: true
    .docker.run
      image: 'httpd'
      port: '499:80'
      name: 'nikita_test_unique'
      detach: true
      rm: false
    .docker.rm
      force: true
      container: 'nikita_test_unique'
    .promise()

  they 'array options', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'nikita_test_array'
    .docker.run
      image: 'httpd'
      port: [ '500:80', '501:81' ]
      name: 'nikita_test_array'
      detach: true
      rm: false
    # .wait_connect
    #   host: ipadress of docker, docker-machine...
    #   port: 500
    .docker.rm
      force: true
      container: 'nikita_test_array'
    .promise()

  they 'existing container', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'nikita_test'
    .docker.run
      cmd: 'echo test'
      image: 'alpine'
      name: 'nikita_test'
      rm: false
    .docker.run
      cmd: "echo test"
      image: 'alpine'
      name: 'nikita_test'
      rm: false
    , (err, {status}) ->
      status.should.be.false() unless err
    .docker.rm
      force: true
      container: 'nikita_test'
    .promise()

  they 'status not modified', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'nikita_test'
    .docker.run
      cmd: 'echo test'
      image: 'alpine'
      name: 'nikita_test'
      rm: false
    .docker.run
      cmd: 'echo test'
      image: 'alpine'
      name: 'nikita_test'
      rm: false
    , (err, {status}) ->
      status.should.be.false() unless err
    .docker.rm
      force: true
      container: 'nikita_test'
    .promise()
