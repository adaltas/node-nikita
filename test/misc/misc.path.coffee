
misc = require '../../src/misc'
{tags} = require '../test'

return unless tags.api

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
