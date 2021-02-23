
{tags} = require '../test'
tilde = require '../../src/utils/tilde'

describe 'utils.tilde', ->
  return unless tags.api

  describe 'normalize', ->

    it 'handle ~', ->
      # wdavidw: 2004 not sure how HOME can be undefined, maybe on windows
      # return unless process.env.HOME
      tilde
      .normalize '~/.ssh'
      .should.finally.eql "#{process.env.HOME}/.ssh"

  describe 'resolve', ->

    it 'handle ~', ->
      # wdavidw: 2004 not sure how HOME can be undefined, maybe on windows
      # return unless process.env.HOME
      tilde
      .resolve '/home/invalid/', '../overwritten', '~/.ssh', 'id_rsa'
      .should.finally.eql "#{process.env.HOME}/.ssh/id_rsa"
