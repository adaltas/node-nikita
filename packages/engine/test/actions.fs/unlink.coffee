
nikita = require '../../src'
utils = require '../../src/utils'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.unlink', ->

  they 'a file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_target"
        content: 'hello'
      @fs.unlink
        target: "{{parent.metadata.tmpdir}}/a_target"
      @fs.exists
        target: "{{parent.metadata.tmpdir}}/a_target"
      .should.be.resolvedWith false

  they 'error ENOENT', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ->
      @fs.unlink
        target: "{{parent.metadata.tmpdir}}/a_target"
      .should.be.rejectedWith
        code: 'NIKITA_FS_UNLINK_ENOENT'
        message: /NIKITA_FS_UNLINK_ENOENT: the file to remove does not exists, got ".*\/a_target"/

  they.skip 'error ENOENT', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    # .fs.mkdir
    #   target: "{{parent.metadata.tmpdir}}/a_directory"
    .fs.unlink
      target: "{{parent.metadata.tmpdir}}/a_target"
    # .should.be.rejectedWith
    #   code: 'NIKITA_FS_UNLINK_EPERM'
    #   # message: /NIKITA_FS_UNLINK_ENOENT: the file to remove does not exists, got ".*\/a_target"/
