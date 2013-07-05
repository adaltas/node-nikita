
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

describe 'ini', ->

  scratch = test.scratch @

  they 'stringify an object', (ssh, next) ->
    mecano.ini
      ssh: ssh
      content: user: preference: color: 'rouge'
      destination: "#{scratch}/user.ini"
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
        return next err if err
        data.should.eql '[user.preference]\ncolor = rouge\n'
        next()

  they 'merge an object', (ssh, next) ->
    content = '[user.preference]\nlanguage = node\ncolor = rouge\n'
    misc.file.writeFile ssh, "#{scratch}/user.ini", content, (err) ->
      return next err if err
      mecano.ini
        ssh: ssh
        content: user: preference: color: 'violet'
        destination: "#{scratch}/user.ini"
        merge: true
      , (err, written) ->
        return next err if err
        written.should.eql 1
        misc.file.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
          return next err if err
          data.should.eql '[user.preference]\nlanguage = node\ncolor = violet\n'
          next()

  they 'discard undefined and null', (ssh, next) ->
    mecano.ini
      ssh: ssh
      content: user: preference: color: 'violet', age: undefined, gender: null
      destination: "#{scratch}/user.ini"
      merge: true
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
        return next err if err
        data.should.eql '[user.preference]\ncolor = violet\n'
        next()

  they 'remove null within merge', (ssh, next) ->
    content = '[user.preference]\nlanguage = node\ncolor = rouge\n'
    misc.file.writeFile ssh, "#{scratch}/user.ini", content, (err) ->
      return next err if err
      mecano.ini
        ssh: ssh
        content: user: preference: color: null
        destination: "#{scratch}/user.ini"
        merge: true
      , (err, written) ->
        return next err if err
        written.should.eql 1
        misc.file.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
          return next err if err
          data.should.eql '[user.preference]\nlanguage = node\n'
          next()

  they 'disregard undefined within merge', (ssh, next) ->
    content = '[user.preference]\nlanguage = node\ncolor = rouge\n'
    misc.file.writeFile ssh, "#{scratch}/user.ini", content, (err) ->
      return next err if err
      mecano.ini
        ssh: ssh
        content: user: preference: color: undefined
        destination: "#{scratch}/user.ini"
        merge: true
      , (err, written) ->
        return next err if err
        written.should.eql 0
        next()

  they 'call stringify udf', (ssh, next) ->
    mecano.ini
      ssh: ssh
      content: user: preference: color: true
      stringify: misc.ini.stringify_square_then_curly
      destination: "#{scratch}/user.ini"
      merge: true
    , (err, written) ->
      return next err if err
      written.should.eql 1
      misc.file.readFile ssh, "#{scratch}/user.ini", 'utf8', (err, data) ->
        return next err if err
        data.should.eql '[user]\n preference = {\n  color = true\n }\n\n'
        next()
