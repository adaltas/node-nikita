
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'ssh.open', ->

  scratch = test.scratch @

  they 'establish a connection', (ssh, next) ->
    return next() unless ssh
    mecano
    .call (options) ->
      (!!options.ssh).should.be.false()
    .ssh.open
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey.privateOrig
      public_key: ssh.config.publicKey.publicOrig
    , (err, status) ->
      status.should.be.true() unless err
    .call (options) ->
      (!!options.ssh).should.be.true()
    .ssh.close()
    .then next

  they 'check status', (ssh, next) ->
    return next() unless ssh
    options = 
      host: ssh.config.host
      port: ssh.config.port
      username: ssh.config.username
      password: ssh.config.password
      private_key: ssh.config.privateKey.privateOrig
      public_key: ssh.config.publicKey.publicOrig
    mecano
    .ssh.open options
    .ssh.open options, (err, status) ->
      status.should.be.false() unless err
    .ssh.close()
    .then next
