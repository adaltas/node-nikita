
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.types.pacman_conf', ->

  scratch = test.scratch @

  they 'empty values dont print values', (ssh) ->
    nikita
      ssh: ssh
    .file.types.pacman_conf
      target: "#{scratch}/pacman.conf"
      content: 'options':
        'Architecture': 'auto'
        'CheckSpace': ''
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/pacman.conf"
      content: '[options]\nArchitecture = auto\nCheckSpace\n'
    .promise()

  they 'boolean values dont print values', (ssh) ->
    nikita
      ssh: ssh
    .file.types.pacman_conf
      target: "#{scratch}/pacman.conf"
      content: 'options':
        'Architecture': 'auto'
        'CheckSpace': true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/pacman.conf"
      content: '[options]\nArchitecture = auto\nCheckSpace\n'
    .promise()

  they 'rootdir with default target', (ssh) ->
    nikita
      ssh: ssh
    .file.types.pacman_conf
      rootdir: "#{scratch}"
      content: 'options':
        'Architecture': 'auto'
        'CheckSpace': true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/etc/pacman.conf"
      content: '[options]\nArchitecture = auto\nCheckSpace\n'
    .promise()
