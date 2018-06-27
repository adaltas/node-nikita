
{EventEmitter} = require 'events'
stream = require 'stream'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.execute option "target"', ->

  scratch = test.scratch @

  they 'require one of bash or arch_linux', (ssh) ->
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
