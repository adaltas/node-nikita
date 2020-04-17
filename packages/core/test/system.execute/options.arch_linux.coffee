
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.system_execute_arc_chroot

describe 'system.execute', ->

  they 'target as string', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "mount --bind /var/tmp/root.x86_64 /mnt"
    .file
      target: '/mnt/root/hello'
      content: "you"
    .system.execute
      arch_chroot: true
      rootdir: '/mnt'
      # target is written to "/tmp" by default which is a mount point
      # so a file in host isnt visible from jail
      target: '/root/my_script'
      cmd: "cat /root/hello"
    , (err, {stdout}) ->
      stdout.should.eql 'you' unless err
    .system.execute
      always: true # todo, need to create this option (run even on error)
      cmd: """
      umount /mnt
      """
    .file.assert
      target: '/mnt/root/hello'
      not: true
    .promise()

  they 'require ', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "echo $BASH"
      arch_chroot: true
      relax: true
    , (err) ->
      err.message.should.equal 'Required Option: "rootdir" with "arch_chroot"'
    .promise()
  
