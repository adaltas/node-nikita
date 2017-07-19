
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'ssh.close', ->

  scratch = test.scratch @

  they 'check status', (ssh) ->
    return @skip() unless ssh
    nikita
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey.privateOrig
      public_key: ssh.config.publicKey.publicOrig
    .ssh.close (err, status) ->
      status.should.be.true() unless err
    .ssh.close (err, status) ->
      status.should.be.false() unless err
    .promise()
