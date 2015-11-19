should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

clean = (ssh, machine, callback) ->
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
          eval $(${bin_machine} env #{machine}) && $bin_docker  rm -f 'mecano_rm' || true
      elif [ -f $bin_boot2docker ];
        then
          eval $(${bin_boot2docker} shellinit) && $bin_docker rm -f 'mecano_rm' || true
      else
        $bin_docker rm -f 'mecano_rm' || true
      fi
      """
    code_skipped: 1
    , (err, executed, stdout, stderr) ->
      return callback err, executed, stdout, stderr


describe 'docker rm', ->

  scratch = test.scratch @
  source = "#{scratch}"
  machine = 'dev'


  they 'remove stopped container', (ssh, next) ->
    clean ssh, machine, (err, executed, stdout, stderr) ->
      mecano
        ssh: ssh
      .docker_run
        cmd: "/bin/echo 'test'"
        image: 'alpine'
        machine: machine
        container: 'mecano_rm'
      .docker_rm
        container: 'mecano_rm'
        machine: machine
      , (err, removed, stdout, stderr) ->
        removed.should.be.true()
      .then next

  they 'remove running container (no force)', (ssh, next) ->
    clean ssh, machine, (err, executed, stdout, stderr) ->
      mecano
        ssh: ssh
      .docker_run
        image: 'httpd'
        port: '499:80'
        machine: machine
        container: 'mecano_rm'
      .docker_rm
        container: 'mecano_rm'
        machine: machine
      , (err, removed, stdout, stderr) ->
        err.message.should.eql 'Container must be stopped to be removed without force'
        next()

  they 'remove running container (with force)', (ssh, next) ->
    clean ssh, machine, (err, executed, stdout, stderr) ->
      mecano
        ssh: ssh
      .docker_run
        image: 'httpd'
        port: '499:80'
        machine: machine
        container: 'mecano_rm'
      .docker_rm
        container: 'mecano_rm'
        machine: machine
        force: true
      , (err, removed, stdout, stderr) ->
        removed.should.be.true()
        clean ssh, machine, (err) -> next(err)
