
# `nikita.ssh.close`

Close the existing connection if any.

## Options

There are no options.

## Source code

    module.exports = handler: ({options}, callback) ->
      @log message: "Entering ssh.close", level: 'DEBUG', module: 'nikita/lib/ssh/close'
      return callback() unless @store['nikita:ssh:connection']
      ssh = @store['nikita:ssh:connection']
      ssh.end()
      ssh.on 'error', (err) -> callback err
      ssh.on 'end', -> callback null, true
      @store['nikita:ssh:connection'] = undefined
