
http = require 'http'
{merge} = require 'mixme'
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

portincr = 22345

server = ->
  _ = null
  port = portincr++
  port: port
  listen: ->
    new Promise (resolve, reject) ->
      _ = http.createServer (req, res) ->
        switch req.url
          when '/'
            res.writeHead 200, 'OK', {'Content-Type': 'application/json'}
            res.end '{"key": "value"}'
          when '/ping'
            body = ''
            req.on 'data', (chunk) ->
              body += chunk.toString()
            req.on 'end', () ->
              res.writeHead 200, 'OK', {'Content-Type': 'application/json'}
              res.end body
          when '/request_404'
            res.writeHead 404, 'Not found'
            res.end()
          when '/request_301'
            res.writeHead 301, 'Moved Permanently',
              'Server': 'Apache/2.4.6 (CentOS) mod_auth_gssapi/1.5.1 mod_nss/1.0.14 NSS/3.28.4 mod_wsgi/3.4 Python/2.7.5'
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
      _.listen port
      .on 'listening', -> resolve()
      .on 'error', (err) -> reject err
  close: ->
    new Promise (resolve) ->
      _.close resolve

describe 'network.http', ->

  they 'a simple json GET', ({ssh}) ->
    srv = server()
    await srv.listen()
    {
      body, data, headers,
      status_code, status_message, type
    } = await nikita.network.http
      ssh: ssh
      url: "http://localhost:#{srv.port}"
    status_code.should.eql 200
    status_message.should.eql 'OK'
    body.should.eql '{"key": "value"}'
    data.should.eql { key: 'value' }
    headers['Content-Type'].should.eql 'application/json'
    type.should.eql 'json'
    srv.close()

  they 'escape single and double quotes', ({ssh}) ->
    srv = server()
    await srv.listen()
    {
      body, data, headers,
      status_code, status_message, type
    } = await nikita.network.http
      ssh: ssh
      url: "http://localhost:#{srv.port}/ping"
      data:
        'te\'st': 'va\'lue'
        'te"st': 'va"lue'
    status_code.should.eql 200
    status_message.should.eql 'OK'
    body.should.eql '{"te\'st":"va\'lue","te\\"st":"va\\"lue"}'
    data.should.eql { 'te\'st': 'va\'lue', 'te"st': 'va"lue' }
    headers['Content-Type'].should.eql 'application/json'
    type.should.eql 'json'
    await srv.close()

  they 'request 404', ({ssh}) ->
    srv = server()
    await srv.listen()
    output = await nikita.network.http
      ssh: ssh
      url: "http://localhost:#{srv.port}/request_404"
    output = merge output, raw: null, logs: [], headers: Date: null
    output.should.eql
      body: ''
      data: undefined
      headers:
        'Date': null
        'Connection': 'keep-alive'
        'Transfer-Encoding': 'chunked'
      http_version: '1.1'
      logs: []
      raw: null
      status: true
      status_code: 404
      status_message: 'Not found'
      type: undefined
    srv.close()

  they 'request 301 from ipa', ({ssh}) ->
    srv = server()
    await srv.listen()
    {status_code} = await nikita.network.http
      ssh: ssh
      url: "http://localhost:#{srv.port}/request_301"
    status_code.should.eql 301
    await srv.close()

  they 'follow redirect', ({ssh}) ->
    srv = server()
    await srv.listen()
    {status_code, data} = await nikita.network.http
      location: true
      ssh: ssh
      url: "http://localhost:#{srv.port}/follow_redirect_1"
    status_code.should.eql 200
    data.should.eql key: 'value'
    await srv.close()

  they 'content type with charset', ({ssh}) ->
    srv = server()
    await srv.listen()
    {status_code, data} = await nikita.network.http
      ssh: ssh
      location: true
      url: "http://localhost:#{srv.port}/content_type_with_charset"
    status_code.should.eql 200
    data.should.eql key: 'value'
    await srv.close()
