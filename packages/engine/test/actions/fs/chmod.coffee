
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.fs.chmod', ->

  they 'create', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_target"
        content: 'hello'
      @fs.chmod
        mode: 0o600
        target: "{{parent.metadata.tmpdir}}/a_target"
      {stats} = await @fs.stat
        target: "{{parent.metadata.tmpdir}}/a_target"
      (stats.mode & 0o777).toString(8).should.eql '600'
