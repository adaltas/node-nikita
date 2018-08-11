
# `nikita.kv.get`

## Source Code

    module.exports = shy: true, handler: (options, callback) ->
      @log message: "Entering kv get", level: 'DEBUG', module: 'nikita/lib/core/kv/get'
      throw Error "Engine already defined" if options.engine and @options.kv
      throw Error "No engine defined" if not options.engine and not @options.kv
      @options.kv.get options.key, (err, value) ->
        callback err, status: true, key: options.key, value: value
