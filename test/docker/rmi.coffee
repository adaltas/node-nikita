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
          eval $(${bin_machine} env #{machine}) && $bin_docker  rmi -f mecano/rmi_test:latest
      elif [ -f $bin_boot2docker ];
        then
          eval $(${bin_boot2docker} shellinit) && $bin_docker rmi -f mecano/rmi_test:latest
      else
        $bin_docker rmi mecano/rmi_test:latest
      fi
      """
    code_skipped: 1
    , (err, executed, stdout, stderr) ->
      return callback err, executed, stdout, stderr


describe 'docker rmi', ->

  scratch = test.scratch @
  source = "#{scratch}"
  machine = 'dev'


  they 'remove image', (ssh, next) ->
    clean ssh, machine, (err, executed, stdout, stderr) ->
      mecano
        ssh: ssh
      .docker_build
        image: 'mecano/rmi_test:latest'
        content: "FROM scratch\nCMD ['echo \"hello build from text\"']"
        machine: machine
      .docker_rmi
        image: 'mecano/rmi_test:latest'
        machine: machine
      , (err, removed, stdout, stderr) ->
        removed.should.be.true()
      .then next

  they 'status unmodifed', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_rmi
      image: 'mecano/rmi_test:latest'
      machine: machine
    .docker_rmi
      image: 'mecano/rmi_test:latest'
      machine: machine
    , (err, removed) ->
      removed.should.be.false()
    .then next
