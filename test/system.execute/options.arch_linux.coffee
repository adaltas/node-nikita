
{EventEmitter} = require 'events'
stream = require 'stream'
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.execute', ->

  config = test.config()
  return  if config.disable_system_execute_arc_chroot
  scratch = test.scratch @
    
  they 'target as true', (ssh) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "mount --bind /var/tmp/root.x86_64 /mnt"
    .file
      target: "/mnt/root/hello"
      content: "you"
    .system.execute
      cmd: "echo $BASH"
      arch_chroot: true
      rootdir: '/mnt'
      # target is written to "/tmp" by default which is a mount point
      # so a file in host isnt visible from jail
      target: true
      cmd: "cat /root/hello"
    , (err, status, stdout, stderr) ->
      stdout.should.eql 'you' unless err
    .system.execute
      always: true # todo, need to create this option (run even on error)
      cmd: "umount /mnt"
    .promise()
      
  they 'target as string', (ssh) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "mount --bind /var/tmp/root.x86_64 /mnt"
    .file
      target: "/mnt/root/hello"
      content: "you"
    .system.execute
      cmd: "echo $BASH"
      arch_chroot: true
      rootdir: '/mnt'
      # target is written to "/tmp" by default which is a mount point
      # so a file in host isnt visible from jail
      target: '/root/my_script'
      cmd: "cat /root/hello"
    , (err, status, stdout, stderr) ->
      stdout.should.eql 'you' unless err
    .system.execute
      always: true # todo, need to create this option (run even on error)
      cmd: """
      umount /mnt
      """
    .promise()
      
  they 'require ', (ssh) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "echo $BASH"
      arch_chroot: true
      relax: true
    , (err, status, stdout, stderr) ->
      err.message.should.equal 'Required Option: "rootdir" with "arch_chroot"'
    .promise()
  
