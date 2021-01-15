
nikita = require '@nikitajs/engine/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita.execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.query', ->

  they 'with path', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {status, data} = await @lxd.query
        path: '/1.0'
      status.should.eql true
      data.api_version.should.eql '1.0'
