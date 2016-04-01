
module.exports = (options, callback) ->
  setImmediate ->
    options.log "Hello #{options.who or 'world'}"
    callback null, true
