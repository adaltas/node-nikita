
nikita = require '@nikitajs/core'
fs = require 'fs'
# Read configuration
try
  config = require process.env['NIKITA_TEST_MODULE'] or '../test'
catch err
  throw err unless err.code is 'MODULE_NOT_FOUND'
  config = fs.readFileSync "#{__dirname}/../test.sample.coffee"
  fs.writeFileSync "#{__dirname}/../test.coffee", config
  config = require '../test.sample.coffee'
if config.yum_over_ssh
  config.yum_over_ssh.username.should.eql 'root' # sudo not yet supported
# Set default scratch directory
config.scratch ?= "/tmp/nikita-test"
# Create scratch dir for every test
beforeEach ->
  nikita
  .system.remove target: config.scratch
  .system.mkdir target: config.scratch, mode: 0o0777
  .promise()
# Export configuration
module.exports = config
