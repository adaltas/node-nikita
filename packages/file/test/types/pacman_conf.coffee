
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.types.pacman_conf', ->
  return unless test.tags.posix

  they 'empty values dont print values', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.pacman_conf
        target: "#{tmpdir}/pacman.conf"
        content: 'options':
          'Architecture': 'auto'
          'CheckSpace': ''
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/pacman.conf"
        content: '[options]\nArchitecture = auto\nCheckSpace\n'

  they 'boolean values dont print values', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.pacman_conf
        target: "#{tmpdir}/pacman.conf"
        content: 'options':
          'Architecture': 'auto'
          'CheckSpace': true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/pacman.conf"
        content: '[options]\nArchitecture = auto\nCheckSpace\n'

  they 'rootdir with default target', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.pacman_conf
        rootdir: "#{tmpdir}"
        content: 'options':
          'Architecture': 'auto'
          'CheckSpace': true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/etc/pacman.conf"
        content: '[options]\nArchitecture = auto\nCheckSpace\n'
