
import path from 'node:path'
import os from 'node:os'
import fs from 'ssh2-fs'
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugins.metadata.tmpdir', ->
  return unless test.tags.sudo

  they 'root ownership', ({ssh}) ->
    nikita
      $ssh: ssh
      $sudo: true
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {stats} = await @fs.stat tmpdir
      stats.should.match
        mode: 0o40744
        uid: 0
        gid: 0
  
