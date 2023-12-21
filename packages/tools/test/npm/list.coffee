
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.npm.list', ->
  return unless test.tags.tools_npm

  they 'option `cwd`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.npm.uninstall
        name: 'csv-parse'
        cwd: tmpdir
      await @tools.npm
        name: 'csv-parse'
        cwd: tmpdir
      {packages} = await @tools.npm.list
        cwd: tmpdir
      packages['csv-parse'].should.be.an.Object()

  they 'option `global`', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @tools.npm.uninstall
        name: 'csv-parse'
        global: true
      await @tools.npm
        name: 'csv-parse'
        global: true
      {packages} = await @tools.npm.list
        global: true
      packages['csv-parse'].should.be.an.Object()
