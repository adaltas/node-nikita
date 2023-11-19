
import tilde from '@nikitajs/core/utils/tilde'
import test from '../test.coffee'

describe 'utils.tilde', ->
  return unless test.tags.api

  describe 'normalize', ->

    it 'handle ~', ->
      tilde
      .normalize '~/.ssh'
      .should.finally.eql "#{process.env.HOME}/.ssh"

  describe 'resolve', ->

    it 'handle ~', ->
      tilde
      .resolve '/home/invalid/', '../overwritten', '~/.ssh', 'id_rsa'
      .should.finally.eql "#{process.env.HOME}/.ssh/id_rsa"
