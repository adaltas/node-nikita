
nikita = require '../../../../src'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.fs.base.readlink', ->

  they 'get value', ({ssh}) ->
    await nikita
      ssh: ssh
      metadata: tmpdir: true
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
