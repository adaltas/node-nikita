
nikita = require '../../src'
utils = require '../../src/utils'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.mkdir', ->

  they 'a file to a directory', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.mkdir
        target: "{{parent.metadata.tmpdir}}/a_directory"
      @fs.stat
        target: "{{parent.metadata.tmpdir}}/a_directory"
      .then ({stats}) ->
        utils.stats.isDirectory(stats.mode).should.be.true()
