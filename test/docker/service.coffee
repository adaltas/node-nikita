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
    if [ -f $bin_machine -a $bin_machine ];
      then
        if [ \"#{machine}\" = \"--\" ];then exit 5;fi
        eval $(${bin_machine} env #{machine}) && $bin_machine  ip #{machine}
    elif [ -f $bin_boot2docker -a $bin_boot2docker ];
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

describe 'docker.service', ->

  config = test.config()
  return if config.disable_docker
  scratch = test.scratch @

  they 'simple service', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      force: true
      container: 'nikita_test_unique'
    .docker.service
      image: 'httpd'
      name: 'nikita_test_unique'
      port: '499:80'
    # .wait_connect
    #   port: 499
    #   host: ipadress of docker, docker-machine...
    .docker.rm
      force: true
      container: 'nikita_test_unique'
    .promise()

  they 'invalid options', (ssh) ->
    nikita
      ssh: ssh
      docker: config.docker
    .docker.rm
      container: 'nikita_test'
      force: true
    .docker.service
      image: 'httpd'
      port: '499:80'
      relax: true
    , (err, executed) ->
      err.message.should.eql 'Missing container name'
    .docker.service
      name: 'toto'
      port: '499:80'
      relax: true
    , (err, executed) ->
      err.message.should.eql 'Missing image'
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
    .docker.service
      name: 'nikita_test'
      image: 'httpd'
      port: '499:80'
    .docker.service
      name: 'nikita_test'
      image: 'httpd'
      port: '499:80'
    , (err, executed, out, serr) ->
      executed.should.be.false()
    .docker.rm
      force: true
      container: 'nikita_test'
    .promise()
