
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'

scratch = "/tmp/mecano-test"

module.exports = 
  scratch: (context) ->
    context.beforeEach (next) ->
      mecano.rm scratch, ->
        mecano.mkdir scratch, next
    context.afterEach (next) ->
      mecano.rm scratch, next
    scratch

