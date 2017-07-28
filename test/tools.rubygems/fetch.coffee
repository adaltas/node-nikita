
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.gem.fetch', ->

  scratch = test.scratch @

  they 'with a version', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.fetch
      name: 'json'
      version: '2.1.0'
      cwd: "#{scratch}"
    , (err, status, filename, filepath) ->
      throw err if err
      status.should.be.true()
      filename.should.eql "json-2.1.0.gem"
      filepath.should.eql "#{scratch}/json-2.1.0.gem"
    .file.assert
      target: "#{scratch}/json-2.1.0.gem"
    .promise()

  they 'without a version', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.fetch
      name: 'json'
      cwd: "#{scratch}"
    , (err, status, filename, filepath) ->
      throw err if err
      status.should.be.true()
      filename.should.eql "json-2.1.0.gem"
      filepath.should.eql "#{scratch}/json-2.1.0.gem"
    .file.assert
      target: "#{scratch}/json-2.1.0.gem"
    .promise()
