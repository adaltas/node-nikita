
path = require 'path'
crypto = require 'crypto'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'

describe 'misc.path', ->

  describe 'normalize', ->

    it 'hanle ~', (next) ->
      return next() unless process.env.HOME
      misc.path.normalize '~/.ssh', (location) ->
        location.should.eql "#{process.env.HOME}/.ssh"
        next()

  describe 'resolve', ->

    it 'hanle ~', (next) ->
      return next() unless process.env.HOME
      misc.path.resolve '/home/toto/', '../lulu', '~/.ssh', 'id_rsa', (location) ->
        location.should.eql "#{process.env.HOME}/.ssh/id_rsa"
        next()
