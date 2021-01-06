
http = require 'http'
nikita = require '@nikitajs/engine/lib'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

portincr = 12345
server = ->
  new Promise (resolve) ->
    srv = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'okay'
    srv.port = portincr++
    srv.close = ( (fn) -> ->
      new Promise (resolve) ->
        fn.call srv, resolve
    )(srv.close)
    srv.listen srv.port, -> resolve srv

describe 'network.tcp.assert', ->

  they 'port and host', ({ssh}) ->
    srv = await server()
    {status} = await nikita.network.tcp.assert
      host: 'localhost'
      port: srv.port
      ssh: ssh
    status.should.be.true()
    await srv.close()

  they 'multiple servers', ({ssh}) ->
    servers = [
      await server()
    ,
      await server()
    ]
    {status} = await nikita.network.tcp.assert
      servers: [
        host: 'localhost', port: '12346'
      ,
        host: 'localhost', port: '12347'
      ]
      ssh: ssh
    status.should.be.true()
    servers.map (srv) ->
      await srv.close()

  they 'port is not listening', ({ssh}) ->
    nikita.network.tcp.assert
      host: 'localhost'
      port: ++portincr
      ssh: ssh
    .should.be.rejectedWith
      message: "Address not listening: \"localhost:#{portincr}\""

  they 'option not', ({ssh}) ->
    {status} = await nikita.network.tcp.assert
      host: 'localhost'
      port: ++portincr
      not: true
      ssh: ssh
    status.should.be.true()
    srv = await server()
    {status} = await nikita.network.tcp.assert
      host: 'localhost'
      port: srv.port
      not: true
      ssh: ssh
    .should.be.rejectedWith
      message: "Address listening: \"localhost:#{srv.port}\""
    await srv.close()
