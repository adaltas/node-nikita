
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.gem.fetch', ->

  config = test.config()
  return if config.disable_tools_rubygems
  scratch = test.scratch @

  they 'with a version', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.fetch
      name: 'execjs'
      version: '2.7.0'
      cwd: "#{scratch}"
    , (err, status, filename, filepath) ->
      throw err if err
      status.should.be.true()
      filename.should.eql "execjs-2.7.0.gem"
      filepath.should.eql "#{scratch}/execjs-2.7.0.gem"
    .file.assert
      target: "#{scratch}/execjs-2.7.0.gem"
    .promise()

  they 'without a version', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.fetch
      name: 'execjs'
      cwd: "#{scratch}"
    , (err, status, filename, filepath) ->
      throw err if err
      status.should.be.true()
      filename.should.eql "execjs-2.7.0.gem"
      filepath.should.eql "#{scratch}/execjs-2.7.0.gem"
    .file.assert
      target: "#{scratch}/execjs-2.7.0.gem"
    .promise()
