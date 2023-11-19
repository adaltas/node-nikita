
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.ssh.keygen', ->
  return unless test.tags.posix

  they 'a new key', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @tools.ssh.keygen
        target: "#{tmpdir}/folder/id_rsa"
        bits: 2048
        comment: 'nikita'
      $status.should.be.true()
      {$status} = await @tools.ssh.keygen
        target: "#{tmpdir}/folder/id_rsa"
        bits: 2048
        comment: 'nikita'
      $status.should.be.false()

    
