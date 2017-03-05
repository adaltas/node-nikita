
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'file.ini', ->

  scratch = test.scratch @

  they 'stringify an object', (ssh, next) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\ncolor = rouge\n'
    .then next

  they 'stringify an object and with custom separator', (ssh, next) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
      separator: ':'
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\ncolor:rouge\n'
    .then next

  they 'merge an object', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: 'violet'
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = violet\n'
    .then next

  they 'discard undefined and null', (ssh, next) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: 'violet', age: undefined, gender: null
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\ncolor = violet\n'
    .then next

  they 'remove null within merge', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: null
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\n'
    .then next

  they 'disregard undefined within merge', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor = rouge\n'
    .file.ini
      content: user: preference: color: undefined
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'call stringify udf', (ssh, next) ->
    nikita
      ssh: ssh
    .file.ini
      content: user: preference: color: true
      stringify: misc.ini.stringify_square_then_curly
      target: "#{scratch}/user.ini"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user]\n preference = {\n  color = true\n }\n\n'
    .then next

  they 'stringify write only key on props', (ssh, next) ->
    nikita
      ssh: ssh
    .file.ini
      content:
        'user':
          'name': 'toto'
          '--hasACar': ''
      target: "#{scratch}/user.ini"
      merge: false
      stringify: misc.ini.stringify_single_key
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user]\nname = toto\n--hasACar\n'
    .then next

  they 'merge ini containing single key lines', (ssh, next) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = node\ncolor\n'
    .file.ini
      content: user: preference: {language: 'c++', color: ''}
      stringify: misc.ini.stringify_single_key
      target: "#{scratch}/user.ini"
      merge: false
    , (err, status) ->
      return next err if err
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.ini"
      content: '[user.preference]\nlanguage = c++\ncolor\n'
    .then next
