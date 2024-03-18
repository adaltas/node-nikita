
import http from 'node:http'
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'network.tcp.assert', ->
  return unless test.tags.posix

  portincr = 22445
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

  they 'port and host', ({ssh}) ->
    try
      srv = await server()
      {$status} = await nikita.network.tcp.assert
        host: 'localhost'
        port: srv.port
        $ssh: ssh
      $status.should.be.true()
    finally
      await srv.close()

  they 'multiple servers', ({ssh}) ->
    try
      servers = [await server(), await server()]
      {$status} = await nikita.network.tcp.assert
        server: [
          host: 'localhost', port: servers[0].port
        ,
          host: 'localhost', port: servers[1].port
        ]
        $ssh: ssh
      $status.should.be.true()
    finally
      servers.map (srv) -> srv.close()

  they 'port is not listening', ({ssh}) ->
    nikita.network.tcp.assert
      host: 'localhost'
      port: ++portincr
      $ssh: ssh
    .should.be.rejectedWith
      message: "Address not listening: \"localhost:#{portincr}\""

  they 'option not', ({ssh}) ->
    {$status} = await nikita.network.tcp.assert
      host: 'localhost'
      port: ++portincr
      not: true
      $ssh: ssh
    $status.should.be.true()
    try
      srv = await server()
      {$status} = await nikita.network.tcp.assert
        host: 'localhost'
        port: srv.port
        not: true
        $ssh: ssh
      .should.be.rejectedWith
        message: "Address listening: \"localhost:#{srv.port}\""
    finally
      await srv.close()
