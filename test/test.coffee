
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'

scratch = "#{__dirname}/../resources/scratch"

module.exports = 
  scratch: (context) ->
    context.beforeEach (next) ->
      mecano.mkdir scratch, next
    context.afterEach (next) ->
      mecano.rm scratch, next
    scratch

