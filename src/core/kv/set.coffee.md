
# `mecano.kv.set(options, [callback])`

## Source Code

    module.exports = (options) ->
      options.log message: "Entering kv set", level: 'DEBUG', module: 'mecano/lib/core/kv/set'
      throw Error "Engine already defined" if options.engine and @options.kv
      throw Error "No engine defined" if not options.engine and not @options.kv
      # @options.kv ?= options.engine
      @options.kv.set options.key, options.value
