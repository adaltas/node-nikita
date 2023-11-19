
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.mod', ->
  return unless test.tags.posix

  they 'activate a module', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {$status} = await @system.mod
        load: false
        modules: 'module_a'
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.true()
      {$status} = await @system.mod
        load: false
        modules: 'module_a'
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.false()
      await @fs.assert
        target: "#{tmpdir}/mods/modules.conf"
        content: "module_a\n"

  they 'activate multiple modules', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {$status} = await @system.mod
        load: false
        modules:
          'module_a': true
          'module_b': true
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.true()
      {$status} = await @system.mod
        load: false
        modules:
          'module_a': true
          'module_b': true
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.false()
      await @fs.assert
        target: "#{tmpdir}/mods/modules.conf"
        content: "module_a\nmodule_b\n"

  they 'desactivate a module', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      {$status} = await @system.mod
        load: false
        modules:
          'module_a': true
          'module_b': true
          'module_c': true
        target: "#{tmpdir}/mods/modules.conf"
      {$status} = await @system.mod
        load: false
        modules:
          'module_a': true
          'module_b': false
          'module_c': true
        target: "#{tmpdir}/mods/modules.conf"
      $status.should.be.true()
      await @fs.assert
        target: "#{tmpdir}/mods/modules.conf"
        content: "module_a\nmodule_c\n"
