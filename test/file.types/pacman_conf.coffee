
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.types.pacman_conf', ->

  scratch = test.scratch @

  they 'empty values dont print values', (ssh, next) ->
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
    .then next

  they 'boolean values dont print values', (ssh, next) ->
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
    .then next

  they 'rootdir with default target', (ssh, next) ->
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
    .then next
