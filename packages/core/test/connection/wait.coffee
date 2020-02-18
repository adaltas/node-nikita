
http = require 'http'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

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

  describe 'validation', ->

    it 'option host', ->
      nikita
      .connection.wait
        servers: [
          { host: undefined, port: 80 }
        ]
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid host: undefined'
      .promise()

    it 'option port', ->
      nikita
      .connection.wait
        servers: [
          { host: 'localhost', port: undefined }
        ]
        relax: true
      , (err) ->
        err.message.should.eql 'Invalid port: undefined'
      .promise()

  describe 'connection', ->

    they 'a single host and a single port', ({ssh}) ->
      srv = server()
      nikita
        ssh: ssh
        srv1: srv
      .on 'stderr_stream', (log) ->
        if /Connection failed/.test log.message?.toString()
          @options.srv1.listen()
      .connection.wait
        interval: 200
        host: 'localhost'
        port: srv.port
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv1.close callback
      .promise()

    they 'server as an object `{host, [port]}`', ({ssh}) ->
      srv1 = server()
      srv2 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .on 'stderr_stream', (log) ->
        if /Connection failed/.test log.message?.toString()
          @options.srv1.listen()
          @options.srv2.listen()
      .connection.wait
        interval: 200
        server: host: 'localhost', port: srv1.port
      , (err, {status}) ->
        status.should.be.true() unless err
      .connection.wait
        interval: 200
        server: host: 'localhost', port: [srv1.port, srv2.port]
      , (err, {status}) ->
        status.should.be.false()
      .call (_, callback) -> @options.srv1.close callback
      .call (_, callback) -> @options.srv2.close callback
      .promise()
      
    they 'server as an array `[{host, port}]`', ({ssh}) ->
      srv1 = server()
      srv2 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .on 'stderr_stream', (log) ->
        if /Connection failed/.test log.message?.toString()
          @options.srv1.listen()
          @options.srv2.listen()
      # .call -> setTimeout @options.srv1.listen, 300
      # .call -> setTimeout @options.srv2.listen, 300
      .connection.wait
        interval: 200
        server: [
          [{host: 'localhost', port: srv1.port}]
          [{host: 'localhost', port: srv2.port}]
        ]
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) -> @options.srv1.close callback
      .call (_, callback) -> @options.srv2.close callback
      .promise()

    they 'server string `host:port`', ({ssh}) ->
      srv = server()
      nikita
        ssh: ssh
        srv: srv
      .on 'stderr_stream', (log) ->
        if /Connection failed/.test log.message?.toString()
          @options.srv.listen()
      .connection.wait
        interval: 200
        server: "localhost:#{srv.port}"
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) -> @options.srv.close callback
      .promise()

    they 'multiple connection', ({ssh}) ->
      srv = server()
      nikita
        ssh: ssh
        srv: srv
      .on 'stderr_stream', (log) ->
        if /Connection failed/.test log.message?.toString()
          @options.srv.listen()
      .connection.wait
        interval: 200
        servers: for i in [0...12]
          {host: 'localhost', port: srv.port}
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) -> @options.srv.close callback
      .promise()

  describe 'options', ->

    they 'test status `false`', ({ssh}) ->
      srv = server()
      nikita
        ssh: ssh
        srv: srv
      .call (_, callback) ->
        @options.srv.listen callback
      .connection.wait
        interval: 200
        host: 'localhost'
        port: srv.port
      , (err, {status}) ->
        status.should.be.false() unless err
      .call (_, callback) ->
        @options.srv.close callback
      .promise()
    
    they 'test status `true`', ({ssh}) ->
      srv = server()
      nikita
        ssh: ssh
        srv: srv
      .on 'stderr_stream', (log) ->
        if /Connection failed/.test log.message?.toString()
          @options.srv.listen()
      .connection.wait
        interval: 200
        host: 'localhost'
        port: srv.port
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv.close callback
      .promise()

    they 'quorum true', ({ssh}) ->
      srv1 = server()
      srv2 = server()
      srv3 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .on 'stderr_stream', (log) ->
        if (new RegExp "Connection failed to localhost:#{srv1.port}").test log.message?.toString()
          @options.srv1.listen()
          @options.srv2.listen()
      .connection.wait
        servers: [
          { host: 'localhost', port: srv1.port }
          { host: 'localhost', port: srv2.port }
          { host: 'localhost', port: srv3.port }
        ]
        quorum: true
        interval: 200
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv1.close callback
      .call (_, callback) ->
        @options.srv2.close callback
      .promise()

    they 'quorum even number', ({ssh}) ->
      srv1 = server()
      srv2 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .on 'stderr_stream', (log) ->
        if (new RegExp "Connection failed to localhost:#{srv1.port}").test log.message?.toString()
          @options.srv1.listen()
      .connection.wait
        interval: 200
        servers: [
          { host: 'localhost', port: srv1.port }
          { host: 'localhost', port: srv2.port }
        ]
        quorum: 1
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv1.close callback
      .promise()

    they 'quorum odd number', ({ssh}) ->
      srv1 = server()
      srv2 = server()
      srv3 = server()
      nikita
        ssh: ssh
        srv1: srv1
        srv2: srv2
      .on 'stderr_stream', (log) ->
        if (new RegExp "Connection failed to localhost:#{srv1.port}").test log.message?.toString()
          @options.srv1.listen()
          @options.srv2.listen()
      .connection.wait
        interval: 200
        servers: [
          { host: 'localhost', port: srv1.port }
          { host: 'localhost', port: srv2.port }
          { host: 'localhost', port: srv3.port }
        ]
        quorum: 2
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        @options.srv1.close callback
      .call (_, callback) ->
        @options.srv2.close callback
      .promise()
