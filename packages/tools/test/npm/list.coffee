
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
      @tools.npm.uninstall
        name: 'csv-parse'
        cwd: tmpdir
      @tools.npm
        name: 'csv-parse'
        cwd: tmpdir
      {packages} = await @tools.npm.list
        cwd: tmpdir
      packages['csv-parse'].should.be.an.Object()

  they 'option `global`', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @tools.npm.uninstall
        name: 'csv-parse'
        global: true
      @tools.npm
        name: 'csv-parse'
        global: true
      {packages} = await @tools.npm.list
        global: true
      packages['csv-parse'].should.be.an.Object()
