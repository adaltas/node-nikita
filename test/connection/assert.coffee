
http = require 'http'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'connection.assert', ->

  servers = []

  afterEach ->
    server.close() for server in servers
    servers = []

  they 'port and host', (ssh) ->
    nikita
      ssh: ssh
    .call (_, handler) ->
      server = http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      server.listen 12345, handler
      servers.push server
    .connection.assert
      host: 'localhost'
      port: '12345'
    .call ->
      @status().should.be.false()
    .promise()

  they 'multiple servers', (ssh) ->
    nikita
      ssh: ssh
    .call (_, handler) ->
      server = http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      server.listen 12346, handler
      servers.push server
    .call (_, handler) ->
      server = http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      server.listen 12347, handler
      servers.push server
    .connection.assert
      servers: [
        host: 'localhost', port: '12346'
      ,
        host: 'localhost', port: '12347'
      ]
    .call ->
      @status().should.be.false()
    .promise()

  they 'port is not listening', (ssh) ->
    nikita
      ssh: ssh
    .connection.assert
      host: 'localhost'
      port: '54321'
      relax: true
    , (err) ->
      err.message.should.eql 'Address not listening: "localhost:54321"'
    .promise()
