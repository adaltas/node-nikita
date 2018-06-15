
# `nikita.connection.assert(options, [callback])`

Assert a TCP or HTTP server is listening. 

## Options

* `host` (string)  
  Host of the targeted server, could be a FQDN, a hostname or an IP.
* `port` (number)  
  Port of the targeted server.
* `server`, `servers` (array|object|string)  
  One or multiple servers, string must be in the form of "{host}:{port}",
  object must have the properties "host" and "port".

## Source code

    module.exports = shy: true, handler: (options) ->
      @log message: "Entering connection.assert", level: 'DEBUG', module: 'nikita/lib/connection/assert'
      options.servers ?= []
      options.servers.push options.server if options.server
      throw Error "Required Option: host is required if port is provided" if options.port and not options.host
      throw Error "Required Option: port is required if host is provided" if options.host and not options.port
      options.servers.push host: options.host, port: options.port if options.host
      for server in options.servers
        @system.execute
          cmd: "bash -c 'echo > /dev/tcp/#{server.host}/#{server.port}'"
        , (err) ->
          throw Error "Address not listening: \"#{server.host}:#{server.port}\"" if err
