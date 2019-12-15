
nikita = require '@nikitajs/core'
fs = require 'fs'
# Read configuration
# try
#   config = require process.env['NIKITA_TEST_MODULE'] or '../test'
# catch err
#   console.log '----', err.errno, err.syscall, err.info, err.message
#   throw err unless err.code is 'MODULE_NOT_FOUND'
#   config = fs.readFileSync "#{__dirname}/../test.sample.coffee"
#   fs.writeFileSync "#{__dirname}/../test.coffee", config
#   config = require '../test.sample.coffee'
# if config.yum_over_ssh
#   config.yum_over_ssh.username.should.eql 'root' # sudo not yet supported
if not process.env['NIKITA_TEST_MODULE'] and (
  not fs.existsSync '../test.js' or
  not fs.existsSync '../test.json' or
  not fs.existsSync '../test.coffee'
)
  config = fs.readFileSync "#{__dirname}/../test.sample.coffee"
  fs.writeFileSync "#{__dirname}/../test.coffee", config
config = require process.env['NIKITA_TEST_MODULE'] or "../test.coffee"
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
