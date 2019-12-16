
nikita = require '../src'
fs = require 'fs'
# Write default configuration
if not process.env['NIKITA_TEST_MODULE'] and (
  not fs.existsSync '../test.js' or
  not fs.existsSync '../test.json' or
  not fs.existsSync '../test.coffee'
)
  config = fs.readFileSync "#{__dirname}/../test.sample.coffee"
  fs.writeFileSync "#{__dirname}/../test.coffee", config
# Read configuration
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
