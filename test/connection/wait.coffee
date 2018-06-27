
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
http = require 'http'

describe 'connection.wait', ->

  scratch = test.scratch @
  port = 12345

  server = (port) ->
    _ = null
    listen: (callback) ->
      _ = http.createServer (req, res) ->
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'okay'
      _.listen port, callback
    close: (callback) ->
      _.close callback

  describe 'connection', ->

    they 'a single host and a single port', (ssh) ->
      port = port++
      nikita
        ssh: ssh
        server1: server port
      .call ->
        setTimeout @options.server1.listen, 200
      .connection.wait
        host: 'localhost'
        port: port
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.server1.close callback
      .promise()

    they 'server object', (ssh) ->
      port1 = port++
      port2 = port++
      nikita
        ssh: ssh
        server1: server port1
        server2: server port2
      .call -> setTimeout @options.server1.listen, 200
      .call -> setTimeout @options.server2.listen, 200
      .connection.wait
        server: host: 'localhost', port: port1
      , (err, {status}) ->
        status.should.be.true() unless err
      .connection.wait
        server: host: 'localhost', port: [port1, port2]
      , (err, {status}) ->
        status.should.be.false()
      .call  (_, callback) -> @options.server1.close callback
      .call  (_, callback) -> @options.server2.close callback
      .call -> setTimeout @options.server1.listen, 200
      .call -> setTimeout @options.server2.listen, 200
      .connection.wait
        server: [
          [{host: 'localhost', port: port1}]
          [{host: 'localhost', port: port2}]
        ]
      , (err, {status}) ->
        status.should.be.true() unless err
      .call  (_, callback) -> @options.server1.close callback
      .call  (_, callback) -> @options.server2.close callback
      .promise()

    they 'server string', (ssh) ->
      port = port++
      nikita
        ssh: ssh
        server1: server port
      .call ->
        setTimeout @options.server1.listen, 200
      .connection.wait
        server: "localhost:#{port}"
      , (err, {status}) ->
        status.should.be.true() unless err
      .call  (_, callback) ->
        @options.server1.close callback
      .promise()

    they 'multiple connection', (ssh) ->
      port = port++
      nikita
        ssh: ssh
        server1: server port
      .call ->
        setTimeout @options.server1.listen, 200
      .connection.wait
        servers: for i in [0...12]
          {host: 'localhost', port: port}
      , (err, {status}) ->
        status.should.be.true() unless err
      .call  (_, callback) ->
        @options.server1.close callback
      .promise()

  describe 'options', ->

    they 'test status', (ssh) ->
      port = port++
      nikita
        ssh: ssh
        server1: server port
      # Status false
      .call (_, callback) ->
        @options.server1.listen callback
      .connection.wait
        host: 'localhost'
        port: port
      , (err, {status}) ->
        status.should.be.false() unless err
      .call  (_, callback) ->
        @options.server1.close callback
      # Status true
      .call ->
        setTimeout @options.server1.listen, 200
      .connection.wait
        host: 'localhost'
        port: port
      , (err, {status}) ->
        status.should.be.true() unless err
      .call  (_, callback) ->
        @options.server1.close callback
      .promise()

    they 'quorum true', (ssh) ->
      port1 = port++
      port2 = port++
      port3 = port++
      nikita
        ssh: ssh
        server1: server port1
        server2: server port2
      .call ->
        setTimeout @options.server1.listen, 200
      .call ->
        setTimeout @options.server2.listen, 200
      .connection.wait
        servers: [
          { host: 'localhost', port: port1 }
          { host: 'localhost', port: port2 }
          { host: 'localhost', port: port3 }
        ]
        quorum: true
        interval: 500
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.server1.close callback
      .call (_, callback) ->
        @options.server2.close callback
      .promise()

    they 'quorum even number', (ssh) ->
      port1 = port++
      port2 = port++
      nikita
        ssh: ssh
        server1: server port1
      .call (_, callback) ->
        @options.server1.listen callback
      .connection.wait
        servers: [
          { host: 'localhost', port: port1 }
          { host: 'localhost', port: port2 }
        ]
        quorum: 1
        interval: 500
      , (err, {status}) ->
        status.should.be.true() unless err
      .call  (_, callback) ->
        @options.server1.close callback
      .promise()

    they 'quorum odd number', (ssh) ->
      port1 = port++
      port2 = port++
      port3 = port++
      nikita
        ssh: ssh
        server1: server port1
        server2: server port2
      .call (_, callback) ->
        @options.server1.listen callback
      .call (_, callback) ->
        @options.server2.listen callback
      .connection.wait
        servers: [
          { host: 'localhost', port: port1 }
          { host: 'localhost', port: port2 }
          { host: 'localhost', port: port3 }
        ]
        quorum: 2
        interval: 500
      , (err, {status}) ->
        status.should.be.true() unless err
      .call  (_, callback) ->
        @options.server1.close callback
      .call  (_, callback) ->
        @options.server2.close callback
      .promise()

  describe 'options', ->

    they 'validate host', (ssh) ->
      port = port++
      nikita
        ssh: ssh
      .connection.wait
        servers: [
          { host: undefined, port: port }
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
