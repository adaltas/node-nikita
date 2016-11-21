
http = require 'http'
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'connection.assert', ->

  scratch = test.scratch @

  server = null

  beforeEach (next) ->
    server = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'okay'
    server.listen 12345, next

  afterEach (next) ->
    server.close next

  they 'port is listening', (ssh, next) ->
    mecano
      ssh: ssh
    .connection.assert
      host: 'localhost'
      port: '12345'
    .then (err, status) ->
      status.should.be.false()
      next err

  they 'port is not listening', (ssh, next) ->
    mecano
      ssh: ssh
    .connection.assert
      host: 'localhost'
      port: '54321'
      relax: true
    , (err) ->
      err.message.should.eql 'Address not listening: "localhost:54321"'
    .then next
