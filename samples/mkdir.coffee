
should = require 'should'
connect = require 'superexec/lib/connect'
mecano = require '..'
config = require '../test'
{uid, gid} = config.ssh_root
console.log '--------------------'
console.log 'config:', config.ssh_root
console.log '--------------------'

connect config.ssh_root, (err, ssh) ->
  mecano.remove
    ssh: ssh
    destination: '/tmp/mecano_sample_mkdir'
  , (err, removed) ->
    mecano.mkdir
      ssh: ssh
      mode: 0o700
      # mode: '700'
      destination: '/tmp/mecano_sample_mkdir/a_dir'
      uid: uid
      gid: gid
    , (err, created) ->
      created.should.eql 1
      mecano.exec
        ssh: ssh
        cmd: 'ls -l /tmp/mecano_sample_mkdir'
      , (err, executed, stdout) ->
        console.log stdout
        ssh.end()
  
