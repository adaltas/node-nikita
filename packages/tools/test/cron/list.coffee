
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.cron.list', ->
  return unless test.tags.tools_cron

  before ->
    @timeout 5*60*1000 # 5mn
    nikita.service 'cronie'

  they 'list entries', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @service 'cronie'
      await @tools.cron.reset()
      {entries} = await @tools.cron.add
        command: "echo cmd 1"
        when: '0 * * * *'
      {entries} = await @tools.cron.add
        command: "echo cmd 2"
        when: '0 * * * *'
      {entries} = await @tools.cron.list()
      entries.should.eql [
        raw: '0 * * * * echo cmd 1'
      ,
        raw: '0 * * * * echo cmd 2'
      ]
