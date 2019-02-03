
http = require 'http'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'connection.wait', ->

  portincr = 12345

  server = ->
    _ = null
    port = portincr++
    port: port
    listen: (callback) ->
      _ = http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      _.listen port, callback
    close: (callback) ->
      _.close callback

  describe 'connection', ->

    they 'a single host and a single port', (ssh) ->
      srv = server()
      nikita
        ssh: ssh
        srv1: srv
      .call ->
        setTimeout @options.srv1.listen, 200
      .connection.wait
        host: 'localhost'
        port: srv.port
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv1.close callback
      .promise()

    they 'server object', (ssh) ->
      srv1 = server()
      srv2 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .call -> setTimeout @options.srv1.listen, 200
      .call -> setTimeout @options.srv2.listen, 200
      .connection.wait
        server: host: 'localhost', port: srv1.port
      , (err, {status}) ->
        status.should.be.true() unless err
      .connection.wait
        server: host: 'localhost', port: [srv1.port, srv2.port]
      , (err, {status}) ->
        status.should.be.false()
      .call (_, callback) -> @options.srv1.close callback
      .call (_, callback) -> @options.srv2.close callback
      .call -> setTimeout @options.srv1.listen, 200
      .call -> setTimeout @options.srv2.listen, 200
      .connection.wait
        server: [
          [{host: 'localhost', port: srv1.port}]
          [{host: 'localhost', port: srv2.port}]
        ]
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) -> @options.srv1.close callback
      .call (_, callback) -> @options.srv2.close callback
      .promise()

    they 'server string', (ssh) ->
      srv = server()
      nikita
        ssh: ssh
        srv: srv
      .call -> setTimeout @options.srv.listen, 200
      .connection.wait
        server: "localhost:#{srv.port}"
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) -> @options.srv.close callback
      .promise()

    they 'multiple connection', (ssh) ->
      srv = server()
      nikita
        ssh: ssh
        srv: srv
      .call -> setTimeout @options.srv.listen, 200
      .connection.wait
        servers: for i in [0...12]
          {host: 'localhost', port: srv.port}
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) -> @options.srv.close callback
      .promise()

  describe 'options', ->

    they 'test status', (ssh) ->
      srv = server()
      nikita
        ssh: ssh
        srv: srv
      # Status false
      .call (_, callback) ->
        @options.srv.listen callback
      .connection.wait
        host: 'localhost'
        port: srv.port
      , (err, {status}) ->
        status.should.be.false() unless err
      .call (_, callback) ->
        @options.srv.close callback
      # Status true
      .call ->
        setTimeout @options.srv.listen, 200
      .connection.wait
        host: 'localhost'
        port: srv.port
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv.close callback
      .promise()

    they 'quorum true', (ssh) ->
      srv1 = server()
      srv2 = server()
      srv3 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .call ->
        setTimeout @options.srv1.listen, 200
      .call ->
        setTimeout @options.srv2.listen, 200
      .connection.wait
        servers: [
          { host: 'localhost', port: srv1.port }
          { host: 'localhost', port: srv2.port }
          { host: 'localhost', port: srv3.port }
        ]
        quorum: true
        interval: 500
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv1.close callback
      .call (_, callback) ->
        @options.srv2.close callback
      .promise()

    they 'quorum even number', (ssh) ->
      srv1 = server()
      srv2 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .call (_, callback) ->
        @options.srv1.listen callback
      .connection.wait
        servers: [
          { host: 'localhost', port: srv1.port }
          { host: 'localhost', port: srv2.port }
        ]
        quorum: 1
        interval: 500
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv1.close callback
      .promise()

    they 'quorum odd number', (ssh) ->
      srv1 = server()
      srv2 = server()
      srv3 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .call (_, callback) ->
        @options.srv1.listen callback
      .call (_, callback) ->
        @options.srv2.listen callback
      .connection.wait
        servers: [
          { host: 'localhost', port: srv1.port }
          { host: 'localhost', port: srv2.port }
          { host: 'localhost', port: srv3.port }
        ]
        quorum: 2
        interval: 500
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv1.close callback
      .call (_, callback) ->
        @options.srv2.close callback
      .promise()

  describe 'options', ->

    they 'validate host', (ssh) ->
      srv = server()
      nikita
        ssh: ssh
      .connection.wait
        servers: [
          { host: undefined, port: srv.port }
        ]
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid host: undefined'
      .promise()

    they 'validate port', (ssh) ->
      nikita
        ssh: ssh
      .connection.wait
        servers: [
          { host: 'localhost', port: undefined }
        ]
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid port: undefined'
      .promise()
