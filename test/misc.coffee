
should = require 'should'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

describe 'misc', ->

  scratch = test.scratch @

  describe 'string', ->

    describe 'hash', ->

      it 'returns the string md5', ->
        md5 = misc.string.hash "hello"
        md5.should.eql '5d41402abc4b2a76b9719d911017c592'

  describe 'ini', ->

    it 'parse in square brackets and curly brackets', ->
      res = misc.ini.stringify_square_then_curly user: preference: color: true
      res.should.eql '[user]\n preference = {\n  color = true\n }\n\n'

  describe 'pidfileStatus', ->

    they 'give 0 if pidfile math a running process', (ssh, next) ->
      misc.file.writeFile ssh, "#{scratch}/pid", "#{process.pid}", (err) ->
        misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
          status.should.eql 0
          next()

    they 'give 1 if pidfile does not exists', (ssh, next) ->
      misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
        status.should.eql 1
        next()

    they 'give 2 if pidfile exists but match no process', (ssh, next) ->
      misc.file.writeFile ssh, "#{scratch}/pid", "666666666", (err) ->
        misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
          status.should.eql 2
          next()






