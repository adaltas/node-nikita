
# `nikita.kv.memory`

## Source Code

    module.exports = ->
      db: {}
      set: (key, value) ->
        @db[key] ?= {}
        @db[key].value = value
        @db[key].listeners ?= []
        while listener = @db[key].listeners.shift()
          listener.call null, null, @db[key].value
      get: (key, callback) ->
        return callback null, @db[key].value if @db[key]?.value
        @db[key] ?= {}
        @db[key].listeners ?= []
        @db[key].listeners.push callback
