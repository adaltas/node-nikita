
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'system.execute option "target"', ->

  they 'require one of bash or arch_linux', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "echo $BASH"
      target: true
      cmd: "cat /root/hello"
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid Option: the "target" option requires either one of the "bash" or "arch_chroot" options'
    .promise()
