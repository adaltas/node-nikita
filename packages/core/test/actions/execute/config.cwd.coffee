
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.execute.config.cwd', ->
  return unless test.tags.system_execute_arc_chroot

  they 'execute in the context of directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {stdout} = await @execute
        command: 'pwd'
        cwd: tmpdir
      stdout.should.eql "#{tmpdir}\n"
  
