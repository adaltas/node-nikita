
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.system_user

describe 'system.mkdir options uid/gid', ->

  they 'change owner uid/gid on creation', ({ssh}) ->
    # 40744: 4 for directory, 744 for permissions
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.group 'toto', gid: 1234
    .system.user 'toto', uid: 1234, gid: 1234
    .system.mkdir
      directory: "#{scratch}/ssh_dir_string"
      uid: 1234
      gid: 1234
    .file.assert
      target: "#{scratch}/ssh_dir_string"
      uid: 1234
      gid: 1234
    .promise()
