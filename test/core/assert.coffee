
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
http = require 'http'

describe 'assert', ->

  scratch = test.scratch @
  
  describe 'status', ->

    they 'false when expected to be false', (ssh, next) ->
      mecano
        ssh: ssh
      .call (_, callback) ->
        callback null, false
      .assert
        status: false
      .then next

    they 'false when expected to be true throw an error', (ssh, next) ->
      mecano
        ssh: ssh
      .call (_, callback) ->
        callback null, false
      .assert
        status: true
      .then (err) ->
        err.message.should.eql 'Invalid status: expected true, got false'
        next()

    they 'true when expected to be true', (ssh, next) ->
      mecano
        ssh: ssh
      .call (_, callback) ->
        callback null, true
      .assert
        status: true
      .then next

    they 'true when expected to be false throw an error', (ssh, next) ->
      mecano
        ssh: ssh
      .call (_, callback) ->
        callback null, true
      .assert
        status: false
      .then (err) ->
        err.message.should.eql 'Invalid status: expected false, got true'
        next()
  
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
    
    they 'succeed', (ssh, next) ->
      mecano
        ssh: ssh
        server: server 12345
      .call (options, callback) ->
        options.server.listen callback
      .assert
        host: 'localhost'
        port: 12345
      .call (options, callback) ->
        options.server.close callback
      .then next
  
    they 'failed', (ssh, next) ->
      mecano
        ssh: ssh
      .assert
        host: 'localhost'
        port: 12345
      .then (err) ->
        err.message.should.eql "Closed Connection to 'localhost:12345'"
        next()
      
