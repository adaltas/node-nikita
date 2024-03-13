
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.resources', ->
  return unless test.tags.incus

  they "check the cpu and the memory", ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status, config} = await @incus.resources()
      $status.should.eql true
      {cpus: config.cpu.total.toString(), memory: config.memory.total.toString()}.should.match {cpus: /^\d+$/, memory: /^\d+$/ }
