
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.chmod', ->

  scratch = test.scratch @

  they 'change a permission of a file', (ssh, next) ->
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
    .then next
