
nikita = require '../../../../src'
{tags, ssh} = require '../../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.base.readlink', ->

  they 'get value', ({ssh}) ->
    res = await nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: ''
      @fs.base.symlink
        source: "{{parent.metadata.tmpdir}}/a_source"
        target: "{{parent.metadata.tmpdir}}/a_target"
      {target} = await @fs.base.readlink
        target: "{{parent.metadata.tmpdir}}/a_target"
      target.should.eql "#{tmpdir}/a_source"
