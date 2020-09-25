
nikita = require '../../../../src'
utils = require '../../../../src/utils'
{tags, ssh} = require '../../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.base.symlink', ->

  they 'create', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_source"
        content: 'hello'
      @fs.base.symlink
        source: "{{parent.metadata.tmpdir}}/a_source"
        target: "{{parent.metadata.tmpdir}}/a_target"
      {stats} = await @fs.base.stat
        target: "{{parent.metadata.tmpdir}}/a_target"
        dereference: false
      utils.stats.isSymbolicLink(stats.mode).should.be.true()
