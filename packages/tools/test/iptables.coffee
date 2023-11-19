
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.iptables', ->
  return unless test.tags.tools_iptables

  they 'insert a rule after existing', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @service
        name: 'iptables-services'
        srv_name: 'iptables'
        state: ['started']
      after = chain: 'INPUT', jump: 'ACCEPT', 'in-interface': 'lo'
      {$status} = await @tools.iptables
        $sudo: true
        rules: [
          chain: 'INPUT', after: after, jump: 'ACCEPT', dport: 22, protocol: 'tcp'
        ]
      $status.should.be.true()
      {stdout} = await @execute
        sudo: true
        command: 'iptables -S'
      stdout.should.containEql [
        '-A INPUT -i lo -j ACCEPT'
        '-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT'
      ].join '\n'
