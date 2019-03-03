
http = require 'http'
mixme = require 'mixme'
nikita = require '../../src'
{tags, ssh  } = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

# portincr = 12345
portincr = 22345

server = ->
  _ = null
  port = portincr++
  port: port
  listen: (callback) ->
    _ = http.createServer (req, res) ->
      switch req.url
        when '/'
          res.writeHead 200, 'OK', {'Content-Type': 'application/json'}
          res.end '{"key": "value"}'
        when '/request_404'
          res.writeHead 404, 'Not found'
          res.end()
        when '/request_301'
          res.writeHead 301, 'Moved Permanently',
            'Server': 'Apache/2.4.6 (CentOS) mod_auth_gssapi/1.5.1 mod_nss/1.0.14 NSS/3.28.4 mod_wsgi/3.4 Python/2.7.5'
            'Set-Cookie': 'ipa_session=;Max-Age=0;path=/ipa;httponly;secure;'
            'X-Frame-Options': 'DENY'
            'Content-Security-Policy': 'frame-ancestors \'none\''
            'Location': 'http://ipa.nikita/ipa/session/json'
            'Cache-Control': 'no-cache'
            'Set-Cookie': 'ipa_session=;Max-Age=0;path=/ipa;httponly;secure;'
            'Content-Length': 241
            'Content-Type': 'text/html; charset=iso-8859-1'
          res.end """
          <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
          <html><head>
          <title>301 Moved Permanently</title>
          </head><body>
          <h1>Moved Permanently</h1>
          <p>The document has moved <a href="http://ipa.nikita/ipa/session/json">here</a>.</p>
          </body></html>
          """
        when '/follow_redirect_1'
          res.writeHead 301, 'Moved Permanently',
            'Location': "http://localhost:#{port}/follow_redirect_2"
          res.end()
        when '/follow_redirect_2'
          res.writeHead 200, 'OK', {'Content-Type': 'application/json'}
          res.end '{"key": "value"}'
        when '/content_type_with_charset'
          res.writeHead 200, 'OK', {'Content-Type': 'application/json; charset=utf-8'}
          res.end '{"key": "value"}'
    _.listen port, callback
  close: (callback) ->
    _.close callback

describe 'connection.http', ->

  they 'a simple json GET', ({ssh}) ->
    srv = server()
    nikita
      ssh: ssh
    .call ({}, callback) ->
      srv.listen callback
    .connection.http
      url: "http://localhost:#{srv.port}"
    , (err, {body, data, headers, status_code, status_message, type}) ->
      throw err if err
      status_code.should.eql 200
      status_message.should.eql 'OK'
      body.should.eql '{"key": "value"}'
      data.should.eql { key: 'value' }
      headers['Content-Type'].should.eql 'application/json'
      type.should.eql 'json'
    .call ({}, callback) -> srv.close callback
    .promise()

  they 'request 404', ({ssh}) ->
    srv = server()
    nikita
      ssh: ssh
    .call ({}, callback) ->
      srv.listen callback
    .connection.http
      url: "http://localhost:#{srv.port}/request_404"
    , (err, output) ->
      throw err if err
      output = mixme output, raw: null, headers: Date: null
      output.should.eql
        body: ''
        headers:
          'Date': null
          'Connection': 'keep-alive'
          'Transfer-Encoding': 'chunked'
        http_version: '1.1'
        raw: null
        status_code: 404
        status_message: 'Not found'
    .call ({}, callback) -> srv.close callback
    .promise()

  they 'request 301 from ipa', ({ssh}) ->
    srv = server()
    nikita
      ssh: ssh
    .call ({}, callback) ->
      srv.listen callback
    .connection.http
      url: "http://localhost:#{srv.port}/request_301"
    , (err, output) ->
      throw err if err
      output.status_code.should.eql 301
    .call ({}, callback) -> srv.close callback
    .promise()

  they 'follow redirect', ({ssh}) ->
    srv = server()
    nikita
      ssh: ssh
    .call ({}, callback) ->
      srv.listen callback
    .connection.http
      url: "http://localhost:#{srv.port}/follow_redirect_1"
      location: true
    , (err, {status_code, data}) ->
      status_code.should.eql 200
      data.should.eql key: 'value'
    .call ({}, callback) -> srv.close callback
    .promise()

  they 'content type with charset', ({ssh}) ->
    srv = server()
    nikita
      ssh: ssh
    .call ({}, callback) ->
      srv.listen callback
    .connection.http
      url: "http://localhost:#{srv.port}/content_type_with_charset"
      location: true
    , (err, {status_code, data}) ->
      status_code.should.eql 200
      data.should.eql key: 'value'
    .call ({}, callback) -> srv.close callback
    .promise()
