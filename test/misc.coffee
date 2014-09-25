
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'misc', ->

  scratch = test.scratch @

  describe 'array', ->

    it 'intersect', ->
      misc.array.intersect(['a', 'c', 'd'], ['e', 'd', 'c']).should.eql ['c', 'd']
      misc.array.intersect(['a', 'c', 'd'], []).should.eql []
      misc.array.intersect([], ['e', 'd', 'c']).should.eql []

  describe 'string', ->

    it 'escapeshellarg', ->
      misc.string.escapeshellarg("try to 'parse this").should.eql "'try to \\'parse this'"

    it 'hash', ->
      md5 = misc.string.hash "hello"
      md5.should.eql '5d41402abc4b2a76b9719d911017c592'

  describe 'object', ->

    describe 'equals', ->

      it 'compare two objects', ->
        misc.object.equals({a: '1', b: '2'}, {a: '1', b: '2'}).should.be.true
        misc.object.equals({a: '1', b: '1'}, {a: '2', b: '2'}).should.be.false
        misc.object.equals({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.be.true
        misc.object.equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'c']).should.be.true
        misc.object.equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'b']).should.be.false

  describe 'pidfileStatus', ->

    they 'give 0 if pidfile math a running process', (ssh, next) ->
      fs.writeFile ssh, "#{scratch}/pid", "#{process.pid}", (err) ->
        misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
          status.should.eql 0
          next()

    they 'give 1 if pidfile does not exists', (ssh, next) ->
      misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
        status.should.eql 1
        next()

    they 'give 2 if pidfile exists but match no process', (ssh, next) ->
      fs.writeFile ssh, "#{scratch}/pid", "666666666", (err) ->
        misc.pidfileStatus ssh, "#{scratch}/pid", (err, status) ->
          status.should.eql 2
          next()

  describe 'args', ->

    it 'accept 2 arguments', ->
      [goptions, options, callback] = misc.args [
        option_a: 'a', option_b: 'b'
        -> #do sth
      ]
      goptions.should.eql parallel: true
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

    it 'accept 3 arguments', ->
      [goptions, options, callback] = misc.args [
        {parallel: 1}
        option_a: 'a', option_b: 'b'
        -> #do sth
      ]
      goptions.should.eql parallel: 1
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function

    it 'overwrite default global options', ->
      [goptions, options, callback] = misc.args [
        option_a: 'a', option_b: 'b'
        -> #do sth
      ], parallel: 1
      goptions.parallel.should.equal 1
      options.should.eql option_a: 'a', option_b: 'b'
      callback.should.be.a.Function






