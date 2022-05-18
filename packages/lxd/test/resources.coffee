
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.resources', ->

  they "check the cpu and the memory", ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status, config} = await @lxc.resources()
      $status.should.eql true
      {cpus: config.cpu.total.toString(), memory: config.memory.total.toString()}.should.match {cpus: /^\d+$/, memory: /^\d+$/ }
