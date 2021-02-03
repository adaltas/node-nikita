
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.system_execute_arc_chroot

describe 'actions.execute.config.cwd', ->

  they 'execute in the context of directory', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {stdout} = await @execute
        command: 'pwd'
        cwd: tmpdir
      stdout.should.eql "#{tmpdir}\n"
  
