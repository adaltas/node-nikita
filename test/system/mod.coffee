
nikita = require '../../src'
misc = require '../../src/misc'
path = require 'path'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'system.mod', ->

  scratch = test.scratch @

  they 'activate a module', (ssh) ->
    nikita
      ssh: ssh
    .system.mod 
      name: 'a_module'
      target: "#{scratch}/mods/modules.conf"
      load: false
    , (err, status) ->
      status.should.be.true() unless err
    .system.mod 
      name: 'a_module'
      target: "#{scratch}/mods/modules.conf"
      load: false
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/mods/modules.conf"
      content: "a_module\n"
    .promise()
