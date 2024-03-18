
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.cron.reset', ->
  return unless test.tags.tools_cron

  before ->
    @timeout 5*60*1000 # 5mn
    nikita.service 'cronie'

  they 'status `false` with no entries', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @service 'cronie'
      await @tools.cron.reset()
      {$status} = await @tools.cron.reset()
      $status.should.be.false()

  they 'status `true` with entries', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @service 'cronie'
      {entries} = await @tools.cron.add
        command: "echo cmd 1"
        when: '0 * * * *'
      {$status} = await @tools.cron.reset()
      $status.should.be.true()
      {entries} = await @tools.cron.list()
      entries.length.should.eql 0
