
# `nikita.ssh.close(options, [callback])`

Close the existing connection if any.

## Options

There are no options.

## Source code

    module.exports = handler: (options, callback) ->
      options.log message: "Entering ssh.close", level: 'DEBUG', module: 'nikita/lib/ssh/close'
      return callback() unless @options.ssh
      @options.ssh.end()
      @options.ssh.on 'error', (err) -> callback err
      @options.ssh.on 'end', -> callback null, true
      @options.ssh = undefined
