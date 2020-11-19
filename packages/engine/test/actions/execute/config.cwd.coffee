
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.system_execute_arc_chroot

describe 'actions.execute.config.cwd', ->

  they 'execute in the context of directory', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {stdout} = await @execute
        cmd: 'pwd'
        cwd: tmpdir
      stdout.should.eql "#{tmpdir}\n"
  
