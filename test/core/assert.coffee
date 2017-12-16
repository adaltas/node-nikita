
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
http = require 'http'

describe 'assert', ->

  scratch = test.scratch @
  
  describe 'status', ->

    they 'false when expected to be false', (ssh) ->
      nikita
        ssh: ssh
      .call (_, callback) ->
        callback null, false
      .assert
        status: false
      .promise()

    they 'false when expected to be true throw an error', (ssh) ->
      nikita
        ssh: ssh
      .call (_, callback) ->
        callback null, false
      .assert
        status: true
      .next (err) ->
        err.message.should.eql 'Invalid status: expected true, got false'
      .promise()

    they 'true when expected to be true', (ssh) ->
      nikita
        ssh: ssh
      .call (_, callback) ->
        callback null, true
      .assert
        status: true
      .promise()

    they 'true when expected to be false throw an error', (ssh) ->
      nikita
        ssh: ssh
      .call (_, callback) ->
        callback null, true
      .assert
        status: false
      .next (err) ->
        err.message.should.eql 'Invalid status: expected false, got true'
      .promise()

  describe 'connection', ->

    server = (port=12345) ->
      _ = null
      listen: (callback) ->
        _ = http.createServer (req, res) ->
          res.writeHead 200, {'Content-Type': 'text/plain'}
          res.end 'okay'
        _.listen port, ->
          setTimeout callback, 2000
      close: (callback) ->
        _.close callback
    
    they 'succeed', (ssh) ->
      nikita
        ssh: ssh
        server: server 12345
      .call (options, callback) ->
        options.server.listen callback
      .assert
        host: 'localhost'
        port: 12345
      .call (options, callback) ->
        options.server.close callback
      .promise()
  
    they 'failed', (ssh) ->
      nikita
        ssh: ssh
      .assert
        host: 'localhost'
        port: 12345
      .next (err) ->
        err.message.should.eql "Closed Connection to 'localhost:12345'"
      .promise()
