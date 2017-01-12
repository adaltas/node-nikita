
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'file.ini', ->

  scratch = test.scratch @

  they 'stringify an object', (ssh, next) ->
    mecano.file.ini
      ssh: ssh
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
    , (err, written) ->
      return next err if err
      written.should.be.true()
      fs.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
        return next err if err
        data.should.eql '[user.preference]\ncolor = rouge\n'
        next()

  they 'stringify an object and with custom separator', (ssh, next) ->
    mecano.file.ini
      ssh: ssh
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.ini"
      separator: ':'
    , (err, written) ->
      return next err if err
      written.should.be.true()
      fs.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
        return next err if err
        data.should.eql '[user.preference]\ncolor:rouge\n'
        next()

  they 'merge an object', (ssh, next) ->
    content = '[user.preference]\nlanguage = node\ncolor = rouge\n'
    fs.writeFile ssh, "#{scratch}/user.ini", content, (err) ->
      return next err if err
      mecano.file.ini
        ssh: ssh
        content: user: preference: color: 'violet'
        target: "#{scratch}/user.ini"
        merge: true
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
          return next err if err
          data.should.eql '[user.preference]\nlanguage = node\ncolor = violet\n'
          next()

  they 'discard undefined and null', (ssh, next) ->
    mecano.file.ini
      ssh: ssh
      content: user: preference: color: 'violet', age: undefined, gender: null
      target: "#{scratch}/user.ini"
      merge: true
    , (err, written) ->
      return next err if err
      written.should.be.true()
      fs.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
        return next err if err
        data.should.eql '[user.preference]\ncolor = violet\n'
        next()

  they 'remove null within merge', (ssh, next) ->
    content = '[user.preference]\nlanguage = node\ncolor = rouge\n'
    fs.writeFile ssh, "#{scratch}/user.ini", content, (err) ->
      return next err if err
      mecano.file.ini
        ssh: ssh
        content: user: preference: color: null
        target: "#{scratch}/user.ini"
        merge: true
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
          return next err if err
          data.should.eql '[user.preference]\nlanguage = node\n'
          next()

  they 'disregard undefined within merge', (ssh, next) ->
    content = '[user.preference]\nlanguage = node\ncolor = rouge\n'
    fs.writeFile ssh, "#{scratch}/user.ini", content, (err) ->
      return next err if err
      mecano.file.ini
        ssh: ssh
        content: user: preference: color: undefined
        target: "#{scratch}/user.ini"
        merge: true
      , (err, written) ->
        return next err if err
        written.should.be.false()
        next()

  they 'call stringify udf', (ssh, next) ->
    mecano.file.ini
      ssh: ssh
      content: user: preference: color: true
      stringify: misc.ini.stringify_square_then_curly
      target: "#{scratch}/user.ini"
      merge: true
    , (err, written) ->
      return next err if err
      written.should.be.true()
      fs.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
        return next err if err
        data.should.eql '[user]\n preference = {\n  color = true\n }\n\n'
        next()

  they 'stringify write only key on props', (ssh, next) ->
    mecano.file.ini
      ssh: ssh
      content:
        'user':
          'name': 'toto'
          '--hasACar': ''
      target: "#{scratch}/user.ini"
      merge: false
      stringify: misc.ini.stringify_single_key
    , (err, written) ->
      return next err if err
      written.should.be.true()
      fs.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
        return next err if err
        data.should.eql '[user]\nname = toto\n--hasACar\n'
        next()

  they 'merge ini containing single key lines', (ssh, next) ->
    content = '[user.preference]\nlanguage = node\ncolor\n'
    fs.writeFile ssh, "#{scratch}/user.ini", content, (err) ->
      return next err if err
      mecano.file.ini
        ssh: ssh
        content: user: preference: {language: 'c++', color: ''}
        stringify: misc.ini.stringify_single_key
        target: "#{scratch}/user.ini"
        merge: false
      , (err, written) ->
        return next err if err
        written.should.be.true()
        fs.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
          return next err if err
          data.should.eql '[user.preference]\nlanguage = c++\ncolor\n'
          next()
