
# `nikita.connection.assert(options, [callback])`

Assert a TCP or HTTP server is listening.

## Source code

    module.exports = shy: true, handler: (options) ->
      options.log message: "Entering connection.assert", level: 'DEBUG', module: 'nikita/lib/connection/assert'
      @system.execute
        cmd: "bash -c 'echo > /dev/tcp/#{options.host}/#{options.port}'"
      , (err) ->
        throw Error "Address not listening: \"#{options.host}:#{options.port}\"" if err
