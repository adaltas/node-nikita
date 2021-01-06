
path = require 'path'
nikita = require '@nikitajs/engine/lib'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'file.upload', ->

  they 'source is missing', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.upload
        target: "#{tmpdir}/#{path.basename __filename}"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `file.upload`:'
        '#/required config should have required property \'source\'.'
      ].join ' '

  they 'target is missing', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.upload
        source: "#{__filename}"
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `file.upload`:'
        '#/required config should have required property \'target\'.'
      ].join ' '

  they 'file into a file', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.upload
        source: "#{__filename}"
        target: "#{tmpdir}/#{path.basename __filename}"
      .should.be.finally.containEql status: true
      @fs.assert
        target: "#{tmpdir}/#{path.basename __filename}"
      @file.upload
        source: "#{__filename}"
        target: "#{tmpdir}/#{path.basename __filename}"
      .should.be.finally.containEql status: false

  they 'file into a directory', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.upload
        source: "#{__filename}"
        target: "#{tmpdir}"
      .should.be.finally.containEql status: true
      @fs.assert
        target: "#{tmpdir}/#{path.basename __filename}"
      @file.upload
        source: "#{__filename}"
        target: "#{tmpdir}"
      .should.be.finally.containEql status: false
