#Be aware to specify the machine if docker mahcine is used

stream = require 'stream'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
docker = require '../../src/docker/commons'

describe 'docker run', ->

  scratch = test.scratch @

  machine = 'ryba'

  they 'test simple command', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      cmd: '/bin/echo test'
      image: 'centos:centos6'
      service: false
      machine: machine
    , (err, executed, stdout, stderr) ->
      stdout.should.match /^test.*/ unless err
    .then next

  they 'test invalid parameter', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      image: 'httpd'
      container: 'mecano_test'
      service: true
      rm: true
      machine: machine
    , (err, executed) ->
      err.message.should.match /^Invalid parameter.*/
    .docker_run
      image: 'httpd'
      service: true
      rm: false
      machine: machine
    , (err, executed) ->
      err.message.should.match /^Invalid parameter.*/
    .then (err) -> next null

  they 'test --rm (flag option)', (ssh, next) ->
    mecano
      ssh: ssh
    .docker_run
      cmd: '/bin/echo test'
      image: 'centos:centos6'
      container: 'mecano_test_rm'
      service: false
      rm: false
      machine: machine
    , (err, executed, stdout, stderr) ->
      stdout.should.match /^test.*/
    .docker_rm
      container: 'mecano_test_rm'
      force: true
      machine: machine
    .then next

  ip = (ssh,  callback) ->
    docker
      .get_provider 
        ssh:  ssh
      , (err, provider) ->
        do_ip(provider) unless err
        return callback err if err
    do_ip = (provider) ->
      #cmd = '/bin/bash -c "echo > /dev/tcp/'
      cmd = ''
      cmd += "docker-machine ip #{machine}" if provider ==  'docker-machine'
      cmd += "boot2docker ip" if provider ==  'boot2docker'
      cmd += "echo '127.0.0.1'" if provider ==  'docker'
      mecano
        ssh: ssh
      .execute
        cmd: cmd
      , (err, executed, stdout, __) ->
        return callback err if err
        ipadress = stdout.trim()
        return callback null, ipadress 

  they 'test unique option from array option', (ssh, next) ->
    ip ssh, (err, ipadress) =>
      return next err if  err
      mecano
        ssh: ssh
      .docker_run
        image: 'httpd'
        port: '499:80'
        machine: machine
        container: 'mecano_test_unique'
      .execute
        cmd: "/bin/bash -c \"echo > /dev/tcp/#{ipadress}/499\""
      .docker_rm
        container: 'mecano_test_unique'
        force: true
        machine: machine
      .then next
      
  they 'test array options', (ssh, next) ->
    ip ssh, (err, ipadress) =>
      return next err if  err
      mecano
        ssh: ssh
      .docker_run
        image: 'httpd'
        port: [ '498:80', '499:81' ]
        machine: machine
        container: 'mecano_test_array'
      .execute
        cmd: "/bin/bash -c \"echo > /dev/tcp/#{ipadress}/498\""
      .docker_rm
        container: 'mecano_test_array'
        force: true
        machine: machine
      .then next

    