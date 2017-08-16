
# `nikita.connection.assert(options, [callback])`

Assert a TCP or HTTP server is listening. 

## Options

* `host` (string)  
  Host of the targeted server, could be a FQDN, a hostname or an IP.   
* `port` (number)  
  Port of the targeted server.   

## Source code

    module.exports = shy: true, handler: (options) ->
      options.log message: "Entering connection.assert", level: 'DEBUG', module: 'nikita/lib/connection/assert'
      @system.execute
        cmd: "bash -c 'echo > /dev/tcp/#{options.host}/#{options.port}'"
      , (err) ->
        throw Error "Address not listening: \"#{options.host}:#{options.port}\"" if err
