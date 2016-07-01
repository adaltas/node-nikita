
mecano = require '../src'
fs = require 'fs'

scratch = "/tmp/mecano-test"

module.exports = 
  scratch: (context) ->
    context.beforeEach (next) ->
      mecano.remove
        target: scratch
      .mkdir target: scratch
      .then next
    scratch
  config: ->
    try
      config = require process.env['MECANO_TEST'] or '../test.coffee'
    catch err
      throw err unless err.code is 'MODULE_NOT_FOUND'
      fs.renameSync "#{__dirname}/../test.coffee.sample", "#{__dirname}/../test.coffee"
      config = require '../test.coffee'
    if config.yum_over_ssh
      config.yum_over_ssh.username.should.eql 'root' # sudo not yet supported
    config
