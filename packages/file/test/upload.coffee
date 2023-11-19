
import path from 'node:path'
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.upload', ->
  return unless test.tags.posix

  they 'source is missing', ({ssh}) ->
    nikita
      $ssh: ssh
    .file.upload
      target: "a_dir/a_file"
    .should.be.rejectedWith [
      'NIKITA_SCHEMA_VALIDATION_CONFIG:'
      'one error was found in the configuration of action `file.upload`:'
      '#/required config must have required property \'source\'.'
    ].join ' '

  they 'target is missing', ({ssh}) ->
    nikita
      $ssh: ssh
    .file.upload
      source: "a_dir/a_file"
    .should.be.rejectedWith [
      'NIKITA_SCHEMA_VALIDATION_CONFIG:'
      'one error was found in the configuration of action `file.upload`:'
      '#/required config must have required property \'target\'.'
    ].join ' '

  they 'file into a file', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.touch "#{tmpdir}/a_file"
      await @fs.mkdir "#{tmpdir}/target_dir"
      await @file.upload
        source: "#{tmpdir}/a_file"
        target: "#{tmpdir}/target_dir/a_file"
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target_dir/a_file"
      await @file.upload
        source: "#{tmpdir}/a_file"
        target: "#{tmpdir}/target_dir/a_file"
      .should.be.finally.containEql $status: false

  they 'file into a directory', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @file.touch "#{tmpdir}/a_file"
      await @fs.mkdir "#{tmpdir}/target_dir"
      await @file.upload
        source: "#{tmpdir}/a_file"
        target: "#{tmpdir}/target_dir"
      .should.be.finally.containEql $status: true
      await @fs.assert
        target: "#{tmpdir}/target_dir/a_file"
      await @file.upload
        source: "#{tmpdir}/a_file"
        target: "#{tmpdir}/target_dir"
      .should.be.finally.containEql $status: false
