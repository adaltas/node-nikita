
nikita = require '../../src'
utils = require '../../src/utils'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.chmod', ->

  they 'create', ({ssh}) ->
    {stats} = await nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_target"
      content: 'hello'
    .fs.chmod
      mode: 0o600
      target: "{{parent.metadata.tmpdir}}/a_target"
    .fs.stat
      target: "{{parent.metadata.tmpdir}}/a_target"
    (stats.mode & 0o777).toString(8).should.eql '600'
