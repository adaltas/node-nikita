
# `nikita.ssh.close`

Close the existing connection if any.

## Options

There are no options.

## Source code

    module.exports = handler: ({options, parent: {state}}) ->
      @log message: "Entering ssh.close", level: 'DEBUG', module: 'nikita/lib/ssh/close'
      return false unless state['nikita:ssh:connection']
      conn = if options.ssh
      then options.ssh
      else state['nikita:ssh:connection']
      new Promise (resolve, reject) ->
        conn.end()
        conn.on 'error', reject
        conn.on 'end', ->
          delete state['nikita:ssh:connection']
          resolve true
