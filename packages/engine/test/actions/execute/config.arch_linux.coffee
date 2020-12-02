
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.system_execute_arc_chroot

describe 'actions.execute.config.arch_linux', ->

  they 'target as string', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @execute
        command: "mount --bind /var/tmp/root.x86_64 /mnt"
      @fs.base.writeFile
        target: '/mnt/root/hello'
        content: "you"
      {stdout} = await @execute
        arch_chroot: true
        rootdir: '/mnt'
        # target is written to "/tmp" by default which is a mount point
        # so a file in host isnt visible from jail
        target: '/root/my_script'
        command: "cat /root/hello"
      stdout.should.eql 'you'
      @execute
        always: true # todo, need to create this option (run even on error)
        command: """
        umount /mnt
        """
      {stats} = await @fs.base.stat
        target: '/mnt/root/hello'
      utils.stats.isFile(stats.mode).should.be.true()

  they 'require ', ({ssh}) ->
    nikita
      ssh: ssh
    .execute
      command: "echo $BASH"
      arch_chroot: true
    .should.be.rejectedWith
      message: 'Required Option: "rootdir" with "arch_chroot"'
  
