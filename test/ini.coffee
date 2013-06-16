
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

describe 'ini', ->

  scratch = test.scratch @

  they 'stringify an object', (ssh, next) ->
    mecano.ini
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
