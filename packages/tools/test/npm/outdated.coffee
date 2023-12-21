
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'tools.npm.outdated', ->
  return unless test.tags.tools_npm

  they 'option `cwd`', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @tools.npm.uninstall
        name: 'csv-parse@'
        cwd: tmpdir
      await @tools.npm
        name: 'csv-parse@3.0.0'
        cwd: tmpdir
      {packages} = await @tools.npm.outdated
        cwd: tmpdir
      {current, wanted} = packages['csv-parse']
      current.should.eql '3.0.0'
      current.should.not.eql wanted

  they 'option `global`', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @tools.npm.uninstall
        name: 'csv-parse'
        global: true
      await @tools.npm
        name: 'csv-parse@3.0.0'
        global: true
      {packages} = await @tools.npm.outdated
        global: true
      {current, wanted} = packages['csv-parse']
      current.should.eql '3.0.0'
      current.should.not.eql wanted
