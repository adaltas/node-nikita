
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'fs.mkdir', ->

  they 'a file to a directory', (ssh) ->
    nikita
      ssh: ssh
    .fs.mkdir
      target: "#{scratch}/a_directory"
    .file.assert
      target: "#{scratch}/a_directory"
      type: 'directory'
    .promise()
