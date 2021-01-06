
nikita = require '@nikitajs/engine/lib'
require '@nikitajs/service/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.tools_iptables

describe 'tools.iptables', ->

  they 'insert a rull after existing', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @service
        config:
          name: 'iptables-services'
          srv_name: 'iptables'
          state: ['started']
      after = chain: 'INPUT', jump: 'ACCEPT', 'in-interface': 'lo'
      {status} = await @tools.iptables
        sudo: true
        rules: [
          chain: 'INPUT', after: after, jump: 'ACCEPT', dport: 22, protocol: 'tcp'
        ]
      status.should.be.true()
      {stdout} = await @execute
        sudo: true
        command: 'iptables -S'
      stdout.should.containEql [
        '-A INPUT -i lo -j ACCEPT'
        '-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT'
      ].join '\n'
