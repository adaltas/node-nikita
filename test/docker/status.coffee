# Be aware to specify the machine if docker mahcine is used
# Some other docker test uses docker_status (start, stop)
# So docker_status should is used by other docker command
# For this purpos ip, and clean are used

stream = require 'stream'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

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
          eval $(${bin_machine} env #{machine}) && $bin_docker  rm -f #{container}
      elif [ -f $bin_boot2docker ];
        then
          eval $(${bin_boot2docker} shellinit) && $bin_docker rm -f #{container}
      else
        $bin_docker rm -f #{container}
      fi
      """
    code_skipped: 1
    , (err, executed, stdout, stderr) ->
      return callback err, executed, stdout, stderr

describe 'docker status', ->

  scratch = test.scratch @

  machine = 'dev'

  they 'on stopped  container', (ssh, next) ->
    clean ssh, machine, 'mecano_status', (err) =>
      mecano
        ssh: ssh
      .docker_run
        cmd: "/bin/echo 'test'"
        image: 'alpine'
        rm: false
        machine: machine
        container: 'mecano_status'
      .docker_status
        container: 'mecano_status'
        machine: machine
      , (err, running, stdout, stderr) ->
        running.should.be.false()
        clean ssh, machine, 'mecano_status', (err) -> next()

  they 'on running container', (ssh, next) ->
    clean ssh, machine, 'mecano_status', (err) =>
      mecano
        ssh: ssh
      .docker_run
        image: 'httpd'
        port: [ '500:80' ]
        machine: machine
        container: 'mecano_status'
      .docker_status
        container: 'mecano_status'
        machine: machine
      , (err, running, stdout, stderr) ->
        running.should.be.true()
        clean ssh, machine, 'mecano_status', (err) -> next()
