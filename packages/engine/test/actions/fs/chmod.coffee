
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'actions.fs.chmod', ->

  they 'change a permission of a file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        content: ''
        mode: 0o0644
        target: "#{tmpdir}/a_file"
      @fs.chmod
        mode: 0o0600
        target: "#{tmpdir}/a_file"
      {stats} = await @fs.base.stat "#{tmpdir}/a_file"
      utils.mode.compare(stats.mode, 0o0600).should.be.true()

  they 'change status', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile
        content: ''
        mode: 0o0754
        target: "#{tmpdir}/a_file"
      {status} = await @fs.chmod
        target: "#{tmpdir}/a_file"
        mode: 0o0744
      status.should.be.true()
      {status} = await @fs.chmod
        target: "#{tmpdir}/a_file"
        mode: 0o0744
      status.should.be.false()
