
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'fs.symlink', ->

  they 'create', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_source"
    .fs.symlink
      target: "#{scratch}/a_target"
      source: "#{scratch}/a_source"
    .file.assert
      target: "#{scratch}/a_target"
      filetype: 'symlink'
    .promise()
