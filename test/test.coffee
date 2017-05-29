
nikita = require '../src'
fs = require 'fs'

scratch = "/tmp/nikita-test"

module.exports = 
  scratch: (context) ->
    context.beforeEach ->
      nikita.system.remove
        target: scratch
      .system.mkdir target: scratch
      .promise()
    scratch
  config: ->
    try
      config = require process.env['MECANO_TEST'] or '../test.coffee'
    catch err
      throw err unless err.code is 'MODULE_NOT_FOUND'
      config = fs.readFileSync "#{__dirname}/../test.sample.coffee"
      fs.writeFileSync "#{__dirname}/../test.coffee", config
      config = require '../test.sample.coffee'
    if config.yum_over_ssh
      config.yum_over_ssh.username.should.eql 'root' # sudo not yet supported
    config
