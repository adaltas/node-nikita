
path = require 'path'
misc = require '../../src/misc'
nikita = require '../../src'
test = require '../test'
fs = require 'ssh2-fs'
they = require 'ssh2-they'

describe 'system.chmod', ->

  scratch = test.scratch @

  they 'change a permission of a file', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
      mode: 0o0600
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        misc.mode.compare(stat.mode, '600').should.eql true unless err
        callback err
    .promise()

  they 'change status', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
      mode: 0o0754
    .system.chmod
      target: "#{scratch}/a_file"
      mode: 0o0744
    , (err, status) ->
      status.should.be.true() unless err
    .system.chmod
      target: "#{scratch}/a_file"
      mode: 0o0744
    , (err, status) ->
      status.should.be.false() unless err
    .promise()
