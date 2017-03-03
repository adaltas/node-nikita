
should = require 'should'
nikita = require '..'
config = require '../test'
{uid, gid} = config.ssh_root
console.log '--------------------'
console.log 'config:', config.ssh_root
console.log '--------------------'

nikita
.ssh.open config.ssh_root
.remove
  ssh: ssh
  target: '/tmp/nikita_sample_mkdir'
.mkdir
  ssh: ssh
  mode: 0o0700
  target: '/tmp/nikita_sample_mkdir/a_dir'
  uid: uid
  gid: gid
, (err, status) ->
  status.should.eql 1
.exec
  ssh: ssh
  cmd: 'ls -l /tmp/nikita_sample_mkdir'
, (err, executed, stdout) ->
  console.log stdout
.ssh.close()
  
