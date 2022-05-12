
nikita = require '@nikitajs/core/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.resources', ->

  they 'cpus', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status, data} = await @lxc.resources
      $status.should.eql true
      data.sockets.cores.core.shoud.eql 0
