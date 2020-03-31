
tilde = require '../../src/misc/tilde'

describe 'tilde', ->

  describe 'normalize', ->

    it 'hanle ~', ->
      # wdavidw: 2004 not sure how HOME can be undefined, maybe on windows
      # return unless process.env.HOME
      tilde
      .normalize '~/.ssh'
      .should.finally.eql "#{process.env.HOME}/.ssh"

  describe 'resolve', ->

    it 'hanle ~', ->
      # wdavidw: 2004 not sure how HOME can be undefined, maybe on windows
      # return unless process.env.HOME
      tilde
      .resolve '/home/invalid/', '../overwritten', '~/.ssh', 'id_rsa'
      .should.finally.eql "#{process.env.HOME}/.ssh/id_rsa"
