
{EventEmitter} = require 'events'
stream = require 'stream'
should = require 'should'
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'

describe 'docker', ->

  scratch = test.scratch @

  they 'run a command', (ssh, next) ->
    mecano
      ssh: ssh
    .docker
      cmd: '/bin/echo test'
      image: 'centos:centos6'
      service: false
    , (err, executed, stdout, stderr) ->
      stdout.should.match /^test.*/
    .then next

  they 'test invalid parameter', (ssh, next) ->
    mecano
      ssh: ssh
    .docker
      image: 'httpd'
      name: 'mecano_test'
      service: true
      rm: true
    , (err, executed) ->
      err.message.should.match /^Invalid parameter.*/
    .docker
      image: 'httpd'
      service: true
      rm: false
    , (err, executed) ->
      err.message.should.match /^Invalid parameter.*/
    .then (err) -> next null

  they 'test --rm (flag option)', (ssh, next) ->
    mecano
      ssh: ssh
    .docker
      cmd: '/bin/echo test'
      image: 'centos:centos6'
      name: 'mecano_test'
      service: false
      rm: false
    , (err, executed, stdout, stderr) ->
      stdout.should.match /^test.*/
    .execute
      cmd: 'docker ps -a | grep mecano_test'
    .execute
      cmd: 'docker stop mecano_test; docker rm mecano_test'
    .then next

  they 'test unique option from array option', (ssh, next) ->
    mecano
      ssh: ssh
    .docker
      image: 'httpd'
      port: '499:80'
      name: 'mecano_test'
    .execute
      cmd: '/bin/bash -c "echo > /dev/tcp/127.0.0.1/499"'
    .execute
      cmd: 'docker stop mecano_test && docker rm mecano_test'
    .then next

  they 'test array options', (ssh, next) ->
    mecano
      ssh: ssh
    .docker
      image: 'httpd'
      port: [ '498:80', '499:81' ]
      name: 'mecano_test'
    .execute
      cmd: '/bin/bash -c "echo > /dev/tcp/127.0.0.1/498"'
    .execute
      cmd: 'docker stop mecano_test && docker rm mecano_test'
    .then next
