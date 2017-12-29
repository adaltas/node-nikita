
# `nikita.ssh.close(options, [callback])`

Close the existing connection if any.

## Options

There are no options.

## Source code

    module.exports = handler: (options, callback) ->
      options.log message: "Entering ssh.close", level: 'DEBUG', module: 'nikita/lib/ssh/close'
      return callback() unless options.store.ssh
      options.store.ssh.end()
      options.store.ssh.on 'error', (err) -> callback err
      options.store.ssh.on 'end', -> callback null, true
      options.store.ssh = undefined
