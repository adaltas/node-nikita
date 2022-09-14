
http = require 'http'
url = require 'url'
querystring = require 'querystring'
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

portincr = 22345
server = ->
  _ = null
  port = portincr++
  srv =
    port: port
    listen: ->
      countInvalidStatus = 500
      new Promise (resolve, reject) ->
        _ = http.createServer (req, res) ->
          switch req.url
            when '/200'
              res.writeHead 200, 'OK', {'Content-Type': 'application/json'}
              res.end '{"key": "value"}'
            when '/200/invalid/status'
              res.writeHead countInvalidStatus, 'OK', {'Content-Type': 'application/json'}
              res.end '{"key": "value"}'
              countInvalidStatus = countInvalidStatus - 100
        _.listen port
        .on 'listening', -> resolve srv
        .on 'error', (err) -> reject err
    close: ->
      new Promise (resolve) ->
        _.close resolve


describe 'run', ->

  they 'code 200 with server started', ({ssh}) ->
    srv = server()
    await srv.listen()
    await nikita
      $ssh: ssh
    , () ->
      {$status} = await @network.http.wait
        url: "http://localhost:#{srv.port}/200"
      $status.should.be.false()
    await srv.close()

  they 'code 200 with server not yet started', ({ssh}) ->
    srv = server()
    await nikita
      $ssh: ssh
    , ({tools: {events}}) ->
      events.on 'text', ({attempt, module}) ->
        return unless module is '@nikitajs/network/src/http/wait'
        srv.listen() if attempt is 0
      {$status} = await @network.http.wait
        url: "http://localhost:#{srv.port}/200"
      $status.should.be.true()
    await srv.close()

  they 'code 200 with invalid previous status', ({ssh}) ->
    srv = server()
    await srv.listen()
    count = 0
    await nikita
      $ssh: ssh
    , ({tools: {events}}) ->
      {$status} = await @network.http.wait
        url: "http://localhost:#{srv.port}/200/invalid/status"
        # status_code: [/^[1|2|3]\d{2}$/]
      $status.should.be.true()
    await srv.close()

  they 'code 200 with invalid previous status', ({ssh}) ->
    await nikita
      $ssh: ssh
    , ({tools: {events}}) ->
      {$status} = await @network.http.wait
        url: "http://localhost:999999"
        interval: 50
        timeout: 200
      .should.be.rejectedWith
        code: 'NIKITA_HTTP_WAIT_TIMEOUT'
        message: 'NIKITA_HTTP_WAIT_TIMEOUT: timeout reached after 200ms.'
      
